# ddp2spi

### Description

- ddp2spi is a cli app for Raspberry Pi's with linux based operating systems, written in Rust.
- It allows receiving **DDP** (Distributed Display Protocol) packets via UDP to show them on **WS2812**/SK6812 LEDs connected to the SPI-MOSI pin of a Raspberry Pi.

### Signal flow

- **Client:**                 The system that creates and sends the frames in DDP-format via UDP.
- **Host (This app):**        ddp2spi processes, translates and passes the frames to the software-driver.
- **Host (Software driver):** [ws2812-spi-rs](https://github.com/smart-leds-rs/ws2812-spi-rs) and [smart-leds-trait](https://github.com/smart-leds-rs/smart-leds-trait) encode the frames into an SPI-compatible bitpattern and pass them to the hardware layer.
- **Host (Hardware driver):** [linux-embedded-hal](https://github.com/rust-embedded/linux-embedded-hal) passes the frames to the hardware driver, which sends the frames to the level shifter via SPI bus.
- **Level shifter:**          The level shifter passes the 3.3V signals from the SPI bus as 5V signals to the LED strip.
- **LED strip:**              An WS2812- or SK6812-strip shows the frames.

### DDP implementation

- To keep the footprint as small as possible, ddp2spi is processing the DDP-packages in a simplified way.
- Bytes 0, 1, 2, 3, 4, 5, 6 and 7 are ignored entirely. See [DDP Documentation](http://www.3waylabs.com/ddp/) to learn what they contain.
- ddp2spi is only processing byte 8 and above and simply treats them as a full frame in RGB data type.

# Requirements

### DDP-client

- ddp2spi is primarily designed to receive packages from [LedFx](https://github.com/ledfx/ledfx).
- It should also work with other clients, **the client must send entire frames in RGB data-type through a single package**.
- For more details read the DDP implementation-section above.

### Host-system

- Use any **Raspberry Pi** with a linux based OS.
- If using **SPI0** (`PIN19`/`GPIO10`), you need to set **`dtparam=spi=on` in `/boot/firmware/config.txt`**.
- If using **SPI1** (`PIN32`/`GPIO20`), you need to set **`dtoverlay=spi1-1cs` in `/boot/firmware/config.txt`**. Be aware DMA is not supported on SPI1, this will put additional load on the CPU.
- The user that runs this app needs to be a member of the `spi` group. **Execute `sudo usermod -aG spi $USER`** and log in again to do that.
- If you are using **more than 318 LEDs**, add **`spidev.bufsiz=65536` in `/boot/firmware/cmdline.txt`** at the end of the first line and reboot. This lifts the kernel limit of 4096 bytes of one SPI write.
- If your **LEDs glitch** or show random frames (always or just sometimes), set **`core_freq_fixed=1` in `/boot/firmware/config.txt`**. This fixes the core- and SPI-frequency, which messes with the signals the ws2812-spi driver sends.

### Level shifter

- SPI MOSI pins usually output 3.3V but WS2812- and SK6812-LED strips are designed to work with 5V.
- According to some reports online, **3.3V** can be sufficient if **short cables** are used. I did not verify this.
- I recommend to **use a level shifter** between the MOSI pin and the LED strip. It can shift the 3.3V- to 5V-signals.
- A good choice is **[Texas Instruments SN74AHCT125N](https://www.ti.com/product/de-de/SN74AHCT125/part-details/SN74AHCT125N)**. It's high quality, cheap and easy to work with.

### LED strip

- **WS2812**- and **SK6812**-LED strips are supported.
- It only works with **RGB-LEDs** (8bit).
- It can handle **up to 480 LEDs** in total.

# Install

```bash
curl -L "https://raw.githubusercontent.com/Switch123456789/ddp2spi/main/root/files/installer.sh" | bash /dev/stdin
```


# Run

### Start app

```bash
./ddp2spi -s 1 --gamma 2.8 --timeout 2
```

 Parameter            | Description
----------------------|-
 `-s <ID>`            | SPI bus ID to send the frames to [default: 0]
 `-f <Hz>`            | SPI frequency in Hz (2000000 - 3800000) [default: 3000000]
 `--gamma <N>`        | Set gamma correction curve (1.0 - 2.2) [default: 1.0]
 `--remote <on\|off>` | Enable/disable processing of DDP packets from other computers [default: true]
 `--timeout <s>`      | Switch all LEDs off when no packet arrived for this many seconds 0 = never [default: 0]
 `--help`             | Print help

### Change settings while running

```bash
echo "gamma 2.8" | sudo socat - UNIX-CONNECT:/run/ddp2spi.sock # using socat
echo "status"    | sudo nc -U -N /run/ddp2spi.sock             # using nc
sudo socat - UNIX-CONNECT:/run/ddp2spi.sock                    # interactive using socat
```

 Command                  | Description 
--------------------------|-
 `gamma <num>`            | Set gamma correction curve (1.0 - 2.2)
 `remote <on\|off>`       | Enable/disable processing of DDP packets from other computers
 `timeout <s>`            | Switch all LEDs off when no packet arrived for this many seconds 0 = never
 `blackout <on\|off>`     | Switch all LEDs off or on
 `status`, `help`, `quit` | Print status/help or quit
 
# Install --------------------------------------------------------------

```bash
sudo useradd --system --groups spi ddp-leds
sudo cp ddp2spi /usr/local/bin/
sudo systemctl enable --now ddp2spi
echo status | sudo socat - UNIX-CONNECT:/run/ddp2spi/control.sock
```