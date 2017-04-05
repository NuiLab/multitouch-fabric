extern crate serial;

use std::env;
use std::time::Duration;

use std::io::prelude::*;
use serial::prelude::*;


// Read data from Arduino Serial Port on PC.
pub fn read_data() {
    serial::open("COM1").unwrap();
    serial::windows::COMPort::open("COM1").unwrap();
}

pub fn interact<T: SerialPort>(port: &mut T) -> serial::Result<()> {
    try!(port.configure(&SETTINGS));
    try!(port.set_timeout(Duration::from_secs(1)));

    let mut buf: Vec<u8> = (0..255).collect();

    println!("reading bytes");
    try!(port.read(&mut buf[..]));

    Ok(())
}

const SETTINGS: serial::PortSettings = serial::PortSettings {
    baud_rate: serial::Baud9600,
    char_size: serial::Bits8,
    parity: serial::ParityNone,
    stop_bits: serial::Stop1,
    flow_control: serial::FlowNone,
};

