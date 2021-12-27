# _____ _____ _____ __ __ _____ _____ 
#|     |   __|     |  |  |     |     |
#|  |  |__   |  |  |_   _|  |  |  |  |
#|_____|_____|_____| |_| |_____|_____|
#
# Project Tutorial Url:http://osoyoo.com/?p=1031
#  
import smbus
import time
import threading

class TalkTimer(threading.Thread):
    def __init__(self):
        super().__init__()
        self.line1 = ""
        self.started = threading.Event()
        self.status = ""
        self.disconnected = False
        self.alive = True
        self.start()

    def __del__(self):
        self.kill()

    def begin(self):
        self.disconnected = False
        self.started.set()

    def end(self):
        self.disconnected = True
        self.started.clear()

    def kill(self):
        self.alive = False
        self.disconnected = True
        self.started.set()
        self.join()

    def run(self):

        while self.alive:

            self.started.wait()

            lcd_init(0x08)
            lcd_string(( "  To:" if self.status == "ringing" else "from:" )+ self.line1, LCD_LINE_1)

            for i in range(60):
                for j in range(60):
                    for k in range(60):

                        if self.disconnected:
                            break

                        hour = str(i).zfill(2)
                        minutes = str(j).zfill(2)
                        secound = str(k).zfill(2)
                        lcd_string("Time:" + hour + ":" + minutes + ":" + secound, LCD_LINE_2)
                        time.sleep(1)

                    else:
                        continue
                    break
                else:
                    continue
                break

            self.started.wait()

# Define some device parameters
I2C_ADDR  = 0x27 # I2C device address, if any error, change this address to 0x3f
LCD_WIDTH = 16   # Maximum characters per line

# Define some device constants
LCD_CHR = 1 # Mode - Sending data
LCD_CMD = 0 # Mode - Sending command

LCD_LINE_1 = 0x80 # LCD RAM address for the 1st line
LCD_LINE_2 = 0xC0 # LCD RAM address for the 2nd line
LCD_LINE_3 = 0x94 # LCD RAM address for the 3rd line
LCD_LINE_4 = 0xD4 # LCD RAM address for the 4th line


ENABLE = 0b00000100 # Enable bit

# Timing constants
E_PULSE = 0.0005
E_DELAY = 0.0005

#Open I2C interface
#bus = smbus.SMBus(0)  # Rev 1 Pi uses 0
bus = smbus.SMBus(1) # Rev 2 Pi uses 1

def lcd_init(backlight):
	# Initialise display
    lcd_byte(0x33,LCD_CMD,backlight) # 110011 Initialise
    lcd_byte(0x32,LCD_CMD,backlight) # 110010 Initialise
    lcd_byte(0x06,LCD_CMD,backlight) # 000110 Cursor move direction
    lcd_byte(0x0C,LCD_CMD,backlight) # 001100 Display On,Cursor Off, Blink Off 
    lcd_byte(0x28,LCD_CMD,backlight) # 101000 Data length, number of lines, font size
    lcd_byte(0x01,LCD_CMD,backlight) # 000001 Clear display
    time.sleep(E_DELAY)

def lcd_byte(bits, mode, backlight):
	# Send byte to data pins
    # bits = the data
    # mode = 1 for data
    #        0 for command

    bits_high = mode | (bits & 0xF0) | backlight
    bits_low = mode | ((bits<<4) & 0xF0) | backlight

    # High bits
    bus.write_byte(I2C_ADDR, bits_high)
    lcd_toggle_enable(bits_high)

    # Low bits
    bus.write_byte(I2C_ADDR, bits_low)
    lcd_toggle_enable(bits_low)

def lcd_toggle_enable(bits):
	# Toggle enable
    time.sleep(E_DELAY)
    bus.write_byte(I2C_ADDR, (bits | ENABLE))
    time.sleep(E_PULSE)
    bus.write_byte(I2C_ADDR,(bits & ~ENABLE))
    time.sleep(E_DELAY)

def lcd_string(message,line):
	# Send string to display

    message = message.ljust(LCD_WIDTH," ")

    lcd_byte(line, LCD_CMD, 0x08)

    for i in range(LCD_WIDTH):
	    lcd_byte(ord(message[i]),LCD_CHR,0x08)

def display_infomation(line1, line2):

    lcd_init(0x08)

    lcd_string(line1, LCD_LINE_1)
    lcd_string(line2, LCD_LINE_2)

def display_backlight_off():

    lcd_byte(0x01, LCD_CMD, 0x00)
