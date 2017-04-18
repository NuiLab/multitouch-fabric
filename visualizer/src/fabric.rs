extern crate serial;
extern crate json;

use serial::SerialPort;
use std::time::Duration;
use std::fs::OpenOptions;
use std::io::{Read, Write};

const DEFAULTCONFIG: &str = "\
{ 
    \"port\": \"\"
}";

const SETTINGS: serial::PortSettings = serial::PortSettings {
    baud_rate: serial::Baud9600,
    char_size: serial::Bits8,
    parity: serial::ParityNone,
    stop_bits: serial::Stop1,
    flow_control: serial::FlowNone,
};

pub struct Input {
    port: Option<serial::windows::COMPort>,
    buf: Vec<u8>,
    pub output: [f32; 16],
}

impl Input {
    pub fn new() -> Input {
        Input {
            port: create_port(),
            buf: vec![0u8; 256],
            output: [0.0; 16],
        }
    }

    // Synchronous Input Update
    pub fn update(&mut self) -> [f32; 16] {

        self.output = [0.0f32; 16];

        match self.port {

            Some(ref mut p) => {
                let mut write = false;
                let mut index = 0;
                loop {

                    match p.read(&mut self.buf) {
                        Ok(size) => {
                            if size == 0 {
                                return self.output;
                            }
                            for i in 0..size {
                                // If index == 16, we're done
                                if index >= self.output.len() {
                                    break;
                                }
                                // if we encounter the header (255), begin pushing data to v.
                                if self.buf[i] == 255 {
                                    write = true;
                                    continue;
                                }

                                if write {
                                    self.output[index] = 1. - self.buf[i] as f32;
                                    index += 1;
                                    if index >= self.output.len() {
                                        break;
                                    }
                                }
                            }
                        }
                        Err(_) => (),
                    };

                    if index >= self.output.len() {
                        break;
                    }
                }
            }
            None => (),
        }


        self.output

    }
}

fn create_port() -> Option<serial::windows::COMPort> {

    use self::SETTINGS;

    let contents = {

        let open = OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .open("config.json");

        let mut contents = String::new();

        let mut file = match open {
            Err(_) => panic!("Couldn't open a handle to ./config.json, are you editing it?"),
            Ok(file) => file,
        };

        match file.read_to_string(&mut contents) {
            Err(_) => panic!("Couldn't read ./config.json, are you editing it?"),
            Ok(_) => println!("Opened config.json file."),
        }

        if contents.is_empty() {

            contents.insert_str(0, DEFAULTCONFIG);

            match file.write_all(contents.as_bytes()) {

                Err(_) => panic!("Couldn't write to ./config.json, are you editing it?"),
                Ok(_) => println!("Created default ./config.json file."),
            }
        }

        contents
    };

    {
        let json_data = match json::parse(&contents) {
            Err(_) => panic!("JSON data couldn't be parsed, verify your JSON."),
            Ok(data) => data,
        };

        let portstr = json_data["port"].as_str();

        match portstr {

            Some(port_name) => {

                let port: Option<serial::windows::COMPort> =
                    match serial::windows::COMPort::open(port_name) {
                        Ok(mut p) => {

                            p.configure(&SETTINGS)
                                .expect("Failed to configure port!");

                            p.set_timeout(Duration::from_millis(16))
                                .expect("Failed to configure port timeout!");

                            Some(p)
                        }
                        Err(_) => None,
                    };

                port
            }
            None => None,
        }
    }
}
