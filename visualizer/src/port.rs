extern crate serial;

use std::time::Duration;
use serial::prelude::*;

pub fn read<T: SerialPort>(port: &mut T, buf: &mut Vec<u8>) -> serial::Result<()> {

    try!(port.configure(&SETTINGS));

    //try!(port.set_timeout(Duration::from_secs(1)));

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

