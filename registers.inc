; -------------
;   PPU Registers
; -------------
.define     INIDISP         2100    ; Display Control 1
.define     OBJSEL          2101    ; Object Size & Object Base
.define     OAMADDL         2102    ; OAM Address, lower byte
.define     OAMADDH         2103    ; OAM Address, bit 9 & Priority Rotation
.define     OAMDATA         2104    ; OAM Data Write
.define     BGMODE          2105    ; BG Mode & BG Character Size
.define     MOSAIC          2106    ; Mosaic Size & Mosaic Enable
.define     BG1SC           2107    ; BG1 Screen Base & Screen Size
.define     BG2SC           2108    ; BG2 Screen Base & Screen Size
.define     BG3SC           2109    ; BG3 Screen Base & Screen Size
.define     BG4SC           210A    ; BG4 Screen Base & Screen Size
.define     BG12NBA         210B    ; BG1/BG2 Character Data Area Designation
.define     BG34NBA         210C    ; BG3/BG4 Character Data Area Designation
.define     BG1HOFS         210D    ; BG1 Horizontal Scroll (X) / M7HOFS
.define     BG1VOFS         210E    ; BG1 Vertical   Scroll (Y) / M7VOFS
.define     BG2HOFS         210F    ; BG2 Horizontal Scroll (X)
.define     BG2VOFS         2110    ; BG2 Vertical   Scroll (Y)
.define     BG3HOFS         2111    ; BG3 Horizontal Scroll (X)
.define     BG3VOFS         2112    ; BG3 Vertical   Scroll (Y)
.define     BG4HOFS         2113    ; BG4 Horizontal Scroll (X)
.define     BG4VOFS         2114    ; BG4 Vertical   Scroll (Y)
.define     VMAINC          2115    ; VRAM Address Increment Mode
.define     VMADDL          2116    ; VRAM Address, lower byte
.define     VMADDH          2117    ; VRAM Address, higher byte
.define     VMDATAL         2118    ; VRAM Data Write, lower byte
.define     VMDATAH         2119    ; VRAM Data Write, higher byte
.define     M7SEL           211A    ; Mode7 Rot/Scale Mode Settings
.define     M7A             211B    ; Mode7 Rot/Scale A (COSINE A) & Maths 16-Bit Operand
.define     M7B             211C    ; Mode7 Rot/Scale B (SINE A)   & Maths  8-bit Operand
.define     M7C             211D    ; Mode7 Rot/Scale C (SINE B)
.define     M7D             211E    ; Mode7 Rot/Scale D (COSINE B)
.define     M7X             211F    ; Mode7 Rot/Scale Center Coordinate X
.define     M7Y             2120    ; Mode7 Rot/Scale Center Coordinate Y
.define     CGADD           2121    ; Palette CGRAM Address
.define     CGDATA          2122    ; Palette CGRAM Data Write
.define     W12SEL          2123    ; Window BG1/BG2  Mask Settings
.define     W34SEL          2124    ; Window BG3/BG4  Mask Settings
.define     WOBJSEL         2125    ; Window OBJ/MATH Mask Settings
.define     WH0             2126    ; Window 1 Left  Position (X1)
.define     WH1             2127    ; Window 1 Right Position (X2)
.define     WH2             2128    ; Window 2 Left  Position (X1)
.define     WH3             2129    ; Window 2 Right Position (X2)
.define     WBGLOG          212A    ; Window 1/2 Mask Logic (BG1..BG4)
.define     WOBJLOG         212B    ; Window 1/2 Mask Logic (OBJ/MATH)
.define     TM              212C    ; Main Screen Designation
.define     TS              212D    ; Sub  Screen Designation
.define     TMW             212E    ; Window Area Main Screen Disable
.define     TSW             212F    ; Window Area Sub  Screen Disable
.define     CGSWSEL         2130    ; Color Math Control Register A
.define     CGADSUB         2131    ; Color Math Control Register B
.define     COLDATA         2132    ; Color Math Sub Screen Backdrop Color
.define     SETINI          2133    ; Display Control 2
; PPU Ports (Read-Only)
.define     MPYL            2134    ; PPU1 Signed Multiply Result (Lower  8-Bit)
.define     MPYM            2135    ; PPU1 Signed Multiply Result (Middle 8-Bit)
.define     MPYH            2136    ; PPU1 Signed Multiply Result (Upper  8-Bit)
.define     SLHV            2137    ; PPU1 Latch H/V-Counter By Software (Read=Strobe)
.define     RDOAM           2138    ; PPU1 OAM  Data Read
.define     RDVRAML         2139    ; PPU1 VRAM  Data Read, lower byte
.define     RDVRAMH         213A    ; PPU1 VRAM  Data Read, higher byte
.define     RDCGRAM         213B    ; PPU2 CGRAM Data Read
.define     OPHCT           213C    ; PPU2 Horizontal Counter Latch
.define     OPVCT           213D    ; PPU2 Vertical   Counter Latch
.define     STAT77          213E    ; PPU1 Status & PPU1 Version Number
.define     STAT78          213F    ; PPU2 Status & PPU2 Version Number
; APU Ports (Read/Write)
.define     APUIO0          2140    ; Main CPU To Sound CPU Communication Port 0
.define     APUIO1          2141    ; Main CPU To Sound CPU Communication Port 1
.define     APUIO2          2142    ; Main CPU To Sound CPU Communication Port 2
.define     APUIO3          2143    ; Main CPU To Sound CPU Communication Port 3
; WRAM Ports
.define     WMDATA          2180    ; WRAM Data Read/Write
.define     WMADDL          2181    ; WRAM Address (Lower  8-Bit)
.define     WMADDM          2182    ; WRAM Address (Middle 8-Bit)
.define     WMADDH          2183    ; WRAM Address (Upper  1-Bit)
; NES Style Joypad Ports
.define     JOYWR           4016    ; Joypad Output
.define     JOYA            4016    ; Joypad Input Register A
.define     JOYB            4017    ; Joypad Input Register B
; -------------
;   CPU Registers
; -------------
.define     NMITIMEN        4200    ; Interrupt Enable & Joypad Request
.define     WRIO            4201    ; Programmable I/O Port (Open-Collector Output)
.define     WRMPYA          4202    ; Set Unsigned  8-Bit Multiplicand
.define     WRMPYB          4203    ; Set Unsigned  8-Bit Multiplier & Start Multiplication
.define     WRDIVL          4204    ; Set Unsigned 16-Bit Dividend, lower byte
.define     WRDIVH          4205    ; Set Unsigned 16-Bit Dividend, higher byte
.define     WRDIVB          4206    ; Set Unsigned  8-Bit Divisor & Start Division
.define     HTIMEL          4207    ; H-Count Timer Setting, lower byte
.define     HTIMEH          4208    ; H-Count Timer Setting (Upper 1bit)
.define     VTIMEL          4209    ; V-Count Timer Setting, lower byte
.define     VTIMEH          420A    ; V-Count Timer Setting (Upper 1-Bit)
.define     MDMAEN          420B    ; Select General Purpose DMA Channels & Start Transfer
.define     HDMAEN          420C    ; Select H-Blank DMA (H-DMA) Channels
.define     MEMSEL          420D    ; Memory-2 Waitstate Control
.define     RDNMI           4210    ; V-Blank NMI Flag and CPU Version Number (Read/Ack)
.define     TIMEUP          4211    ; H/V-Timer IRQ Flag (Read/Ack)
.define     HVBJOY          4212    ; H/V-Blank Flag & Joypad Busy Flag
.define     RDIO            4213    ; Joypad Programmable I/O Port (Input)
.define     RDDIVL          4214    ; Unsigned Div Result (Quotient), lower byte
.define     RDDIVH          4215    ; Unsigned Div Result (Quotient), higher byte
.define     RDMPYL          4216    ; Unsigned Div Remainder / Mul Product, lower byte
.define     RDMPYH          4217    ; Unsigned Div Remainder / Mul Product, higher byte
.define     JOY1L           4218    ; Joypad 1 (Gameport 1, Pin 4), lower byte
.define     JOY1H           4219    ; Joypad 1 (Gameport 1, Pin 4), higher byte
.define     JOY2L           421A    ; Joypad 2 (Gameport 2, Pin 4), lower byte
.define     JOY2H           421B    ; Joypad 2 (Gameport 2, Pin 4), higher byte
.define     JOY3L           421C    ; Joypad 3 (Gameport 1, Pin 5), lower byte
.define     JOY3H           421D    ; Joypad 3 (Gameport 1, Pin 5), higher byte
.define     JOY4L           421E    ; Joypad 4 (Gameport 2, Pin 5), lower byte
.define     JOY4H           421F    ; Joypad 4 (Gameport 2, Pin 5), higher byte
; -------------
;   DMA Registers
; -------------
.define     DMAP0           4300    ; DMA0 DMA/HDMA Parameters
.define     BBAD0           4301    ; DMA0 DMA/HDMA I/O-Bus Address (PPU-Bus AKA B-Bus)
.define     A1T0L           4302    ; DMA0 DMA/HDMA Table Start Address, lower byte
.define     A1T0H           4303    ; DMA0 DMA/HDMA Table Start Address, higher byte
.define     A1T0B           4304    ; DMA0 DMA/HDMA Table Start Address (Bank)
.define     DAS0L           4305    ; DMA0 DMA Count, lower byte
.define     DAS0H           4306    ; DMA0 DMA Count, higher byte
.define     DAS0B           4307    ; DMA0 Indirect HDMA Address (Bank)
.define     A2A0L           4308    ; DMA0 HDMA Table Address, lower byte
.define     A2A0H           4309    ; DMA0 HDMA Table Address, higher byte
.define     NTRL0           430A    ; DMA0 HDMA Line-Counter

.define     DMAP1           4310    ; DMA1 DMA/HDMA Parameters
.define     BBAD1           4311    ; DMA1 DMA/HDMA I/O-Bus Address (PPU-Bus AKA B-Bus)
.define     A1T1L           4312    ; DMA1 DMA/HDMA Table Start Address, lower byte
.define     A1T1H           4313    ; DMA1 DMA/HDMA Table Start Address, higher byte
.define     A1T1B           4314    ; DMA1 DMA/HDMA Table Start Address (Bank)
.define     DAS1L           4315    ; DMA1 DMA Count, lower byte
.define     DAS1H           4316    ; DMA1 DMA Count, higher byte
.define     DAS1B           4317    ; DMA1 Indirect HDMA Address (Bank)
.define     A2A1L           4318    ; DMA1 HDMA Table Address, lower byte
.define     A2A1H           4319    ; DMA1 HDMA Table Address, higher byte
.define     NTRL1           431A    ; DMA1 HDMA Line-Counter

.define     DMAP2           4320    ; DMA2 DMA/HDMA Parameters
.define     BBAD2           4321    ; DMA2 DMA/HDMA I/O-Bus Address (PPU-Bus AKA B-Bus)
.define     A1T2L           4322    ; DMA2 DMA/HDMA Table Start Address, lower byte
.define     A1T2H           4323    ; DMA2 DMA/HDMA Table Start Address, higher byte
.define     A1T2B           4324    ; DMA2 DMA/HDMA Table Start Address (Bank)
.define     DAS2L           4325    ; DMA2 DMA Count, lower byte
.define     DAS2H           4326    ; DMA2 DMA Count, higher byte
.define     DAS2B           4327    ; DMA2 Indirect HDMA Address (Bank)
.define     A2A2L           4328    ; DMA2 HDMA Table Address, lower byte
.define     A2A2H           4329    ; DMA2 HDMA Table Address, higher byte
.define     NTRL2           432A    ; DMA2 HDMA Line-Counter

.define     DMAP3           4330    ; DMA3 DMA/HDMA Parameters
.define     BBAD3           4331    ; DMA3 DMA/HDMA I/O-Bus Address (PPU-Bus AKA B-Bus)
.define     A1T3L           4332    ; DMA3 DMA/HDMA Table Start Address, lower byte
.define     A1T3H           4333    ; DMA3 DMA/HDMA Table Start Address, higher byte
.define     A1T3B           4334    ; DMA3 DMA/HDMA Table Start Address (Bank)
.define     DAS3L           4335    ; DMA3 DMA Count, lower byte
.define     DAS3H           4336    ; DMA3 DMA Count, higher byte
.define     DAS3B           4337    ; DMA3 Indirect HDMA Address (Bank)
.define     A2A3L           4338    ; DMA3 HDMA Table Address, lower byte
.define     A2A3H           4339    ; DMA3 HDMA Table Address, higher byte
.define     NTRL3           433A    ; DMA3 HDMA Line-Counter

.define     DMAP4           4340    ; DMA4 DMA/HDMA Parameters
.define     BBAD4           4341    ; DMA4 DMA/HDMA I/O-Bus Address (PPU-Bus AKA B-Bus)
.define     A1T4L           4342    ; DMA4 DMA/HDMA Table Start Address, lower byte
.define     A1T4H           4343    ; DMA4 DMA/HDMA Table Start Address, higher byte
.define     A1T4B           4344    ; DMA4 DMA/HDMA Table Start Address (Bank)
.define     DAS4L           4345    ; DMA4 DMA Count, lower byte
.define     DAS4H           4346    ; DMA4 DMA Count, higher byte
.define     DAS4B           4347    ; DMA4 Indirect HDMA Address (Bank)
.define     A2A4L           4348    ; DMA4 HDMA Table Address, lower byte
.define     A2A4H           4349    ; DMA4 HDMA Table Address, higher byte
.define     NTRL4           434A    ; DMA4 HDMA Line-Counter

.define     DMAP5           4350    ; DMA5 DMA/HDMA Parameters
.define     BBAD5           4351    ; DMA5 DMA/HDMA I/O-Bus Address (PPU-Bus AKA B-Bus)
.define     A1T5L           4352    ; DMA5 DMA/HDMA Table Start Address, lower byte
.define     A1T5H           4353    ; DMA5 DMA/HDMA Table Start Address, higher byte
.define     A1T5B           4354    ; DMA5 DMA/HDMA Table Start Address (Bank)
.define     DAS5L           4355    ; DMA5 DMA Count, lower byte
.define     DAS5H           4356    ; DMA5 DMA Count, higher byte
.define     DAS5B           4357    ; DMA5 Indirect HDMA Address (Bank)
.define     A2A5L           4358    ; DMA5 HDMA Table Address, lower byte
.define     A2A5H           4359    ; DMA5 HDMA Table Address, higher byte
.define     NTRL5           435A    ; DMA5 HDMA Line-Counter

.define     DMAP6           4360    ; DMA6 DMA/HDMA Parameters
.define     BBAD6           4361    ; DMA6 DMA/HDMA I/O-Bus Address (PPU-Bus AKA B-Bus)
.define     A1T6L           4362    ; DMA6 DMA/HDMA Table Start Address, lower byte
.define     A1T6H           4363    ; DMA6 DMA/HDMA Table Start Address, higher byte
.define     A1T6B           4364    ; DMA6 DMA/HDMA Table Start Address (Bank)
.define     DAS6L           4365    ; DMA6 DMA Count, lower byte
.define     DAS6H           4366    ; DMA6 DMA Count, higher byte
.define     DAS6B           4367    ; DMA6 Indirect HDMA Address (Bank)
.define     A2A6L           4368    ; DMA6 HDMA Table Address, lower byte
.define     A2A6H           4369    ; DMA6 HDMA Table Address, higher byte
.define     NTRL6           436A    ; DMA6 HDMA Line-Counter

.define     DMAP7           4370    ; DMA7 DMA/HDMA Parameters
.define     BBAD7           4371    ; DMA7 DMA/HDMA I/O-Bus Address (PPU-Bus AKA B-Bus)
.define     A1T7L           4372    ; DMA7 DMA/HDMA Table Start Address, lower byte
.define     A1T7H           4373    ; DMA7 DMA/HDMA Table Start Address, higher byte
.define     A1T7B           4374    ; DMA7 DMA/HDMA Table Start Address (Bank)
.define     DAS7L           4375    ; DMA7 DMA Count, lower byte
.define     DAS7H           4376    ; DMA7 DMA Count, higher byte
.define     DAS7B           4377    ; DMA7 Indirect HDMA Address (Bank)
.define     A2A7L           4378    ; DMA7 HDMA Table Address, lower byte
.define     A2A7H           4379    ; DMA7 HDMA Table Address, higher byte
.define     NTRL7           437A    ; DMA7 HDMA Line-Counter
