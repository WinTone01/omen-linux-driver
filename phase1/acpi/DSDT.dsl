/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260408 (32-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of DSDT.aml
 *
 * Original Table Header:
 *     Signature        "DSDT"
 *     Length           0x0001D0A5 (118949)
 *     Revision         0x02
 *     Checksum         0x37
 *     OEM ID           "HPQOEM"
 *     OEM Table ID     "8D24    "
 *     OEM Revision     0x01072009 (17244169)
 *     Compiler ID      "ACPI"
 *     Compiler Version 0x20230331 (539165489)
 */
DefinitionBlock ("", "DSDT", 2, "HPQOEM", "8D24    ", 0x01072009)
{
    External (_SB_.ALIB, MethodObj)    // 2 Arguments
    External (_SB_.APTS, MethodObj)    // 1 Arguments
    External (_SB_.AWAK, MethodObj)    // 1 Arguments
    External (_SB_.FAN0, DeviceObj)
    External (_SB_.FAN0.FSLV, IntObj)
    External (_SB_.NPCF, DeviceObj)
    External (_SB_.NPCF.ACBT, IntObj)
    External (_SB_.NPCF.AMAT, IntObj)
    External (_SB_.NPCF.AMIT, IntObj)
    External (_SB_.NPCF.ATPP, IntObj)
    External (_SB_.NPCF.CTGP, IntObj)
    External (_SB_.NPCF.DATP, IntObj)
    External (_SB_.NPCF.DBAC, IntObj)
    External (_SB_.NPCF.DBDC, IntObj)
    External (_SB_.NPCF.DTGP, IntObj)
    External (_SB_.PCI0.GFX0.VGA_.LCD_, DeviceObj)
    External (_SB_.PCI0.GPP9.GSTA, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.GPP9.PEGP, DeviceObj)
    External (_SB_.PCI0.GPP9.PEGP.CTGP, IntObj)
    External (_SB_.PCI0.GPP9.PEGP.EDP1, DeviceObj)
    External (_SB_.PCI0.GPP9.PEGP.GPST, IntObj)
    External (_SB_.PCI0.GPP9.PEGP.GPUT, IntObj)
    External (_SB_.PCI0.GPP9.SWUS.SWDS.VGA_, DeviceObj)
    External (_SB_.PCI0.GPP9.SWUS.SWDS.VGA_.LCD_, DeviceObj)
    External (_SB_.PCI0.GPPA.VGA_, DeviceObj)
    External (_SB_.PCI0.GPPA.VGA_.LCD_, DeviceObj)
    External (_SB_.PCI0.SBRG.EC0_.CSP1, IntObj)
    External (_SB_.PCI0.SBRG.EC0_.CSP2, IntObj)
    External (_SB_.PCI0.SBRG.EC0_.ECON, IntObj)
    External (_SB_.PCI0.SBRG.EC0_.R4D6, IntObj)
    External (_SB_.PCI0.SBRG.EC0_.R4D7, IntObj)
    External (_SB_.PLTF.C000, UnknownObj)
    External (_SB_.PLTF.C000.PPCV, IntObj)
    External (_SB_.PLTF.C001, UnknownObj)
    External (_SB_.PLTF.C001.PPCV, IntObj)
    External (_SB_.PLTF.C002, UnknownObj)
    External (_SB_.PLTF.C002.PPCV, IntObj)
    External (_SB_.PLTF.C003, UnknownObj)
    External (_SB_.PLTF.C003.PPCV, IntObj)
    External (_SB_.PLTF.C004, UnknownObj)
    External (_SB_.PLTF.C004.PPCV, IntObj)
    External (_SB_.PLTF.C005, UnknownObj)
    External (_SB_.PLTF.C005.PPCV, IntObj)
    External (_SB_.PLTF.C006, UnknownObj)
    External (_SB_.PLTF.C006.PPCV, IntObj)
    External (_SB_.PLTF.C007, UnknownObj)
    External (_SB_.PLTF.C007.PPCV, IntObj)
    External (_SB_.PLTF.C008, UnknownObj)
    External (_SB_.PLTF.C008.PPCV, IntObj)
    External (_SB_.PLTF.C009, UnknownObj)
    External (_SB_.PLTF.C009.PPCV, IntObj)
    External (_SB_.PLTF.C00A, UnknownObj)
    External (_SB_.PLTF.C00A.PPCV, IntObj)
    External (_SB_.PLTF.C00B, UnknownObj)
    External (_SB_.PLTF.C00B.PPCV, IntObj)
    External (_SB_.PLTF.C00C, UnknownObj)
    External (_SB_.PLTF.C00C.PPCV, IntObj)
    External (_SB_.PLTF.C00D, UnknownObj)
    External (_SB_.PLTF.C00D.PPCV, IntObj)
    External (_SB_.PLTF.C00E, UnknownObj)
    External (_SB_.PLTF.C00E.PPCV, IntObj)
    External (_SB_.PLTF.C00F, UnknownObj)
    External (_SB_.PLTF.C00F.PPCV, IntObj)
    External (_SB_.U4PC, IntObj)
    External (_SB_.UBTC, UnknownObj)
    External (_SB_.UBTC.CCI0, IntObj)
    External (_SB_.UBTC.CCI1, IntObj)
    External (_SB_.UBTC.CCI2, IntObj)
    External (_SB_.UBTC.CCI3, IntObj)
    External (_SB_.UBTC.CTL0, IntObj)
    External (_SB_.UBTC.CTL1, IntObj)
    External (_SB_.UBTC.CTL2, IntObj)
    External (_SB_.UBTC.CTL3, IntObj)
    External (_SB_.UBTC.CTL4, IntObj)
    External (_SB_.UBTC.CTL5, IntObj)
    External (_SB_.UBTC.CTL6, IntObj)
    External (_SB_.UBTC.CTL7, IntObj)
    External (_SB_.UBTC.MGI0, IntObj)
    External (_SB_.UBTC.MGI1, IntObj)
    External (_SB_.UBTC.MGI2, IntObj)
    External (_SB_.UBTC.MGI3, IntObj)
    External (_SB_.UBTC.MGI4, IntObj)
    External (_SB_.UBTC.MGI5, IntObj)
    External (_SB_.UBTC.MGI6, IntObj)
    External (_SB_.UBTC.MGI7, IntObj)
    External (_SB_.UBTC.MGI8, IntObj)
    External (_SB_.UBTC.MGI9, IntObj)
    External (_SB_.UBTC.MGIA, IntObj)
    External (_SB_.UBTC.MGIB, IntObj)
    External (_SB_.UBTC.MGIC, IntObj)
    External (_SB_.UBTC.MGID, IntObj)
    External (_SB_.UBTC.MGIE, IntObj)
    External (_SB_.UBTC.MGIF, IntObj)
    External (_SB_.UBTC.MGO0, IntObj)
    External (_SB_.UBTC.MGO1, IntObj)
    External (_SB_.UBTC.MGO2, IntObj)
    External (_SB_.UBTC.MGO3, IntObj)
    External (_SB_.UBTC.MGO4, IntObj)
    External (_SB_.UBTC.MGO5, IntObj)
    External (_SB_.UBTC.MGO6, IntObj)
    External (_SB_.UBTC.MGO7, IntObj)
    External (_SB_.UBTC.MGO8, IntObj)
    External (_SB_.UBTC.MGO9, IntObj)
    External (_SB_.UBTC.MGOA, IntObj)
    External (_SB_.UBTC.MGOB, IntObj)
    External (_SB_.UBTC.MGOC, IntObj)
    External (_SB_.UBTC.MGOD, IntObj)
    External (_SB_.UBTC.MGOE, IntObj)
    External (_SB_.UBTC.MGOF, IntObj)
    External (_SB_.UBTC.VER0, IntObj)
    External (_SB_.UBTC.VER1, IntObj)
    External (AFN4, MethodObj)    // 1 Arguments
    External (AFN7, MethodObj)    // 1 Arguments
    External (CRBI, UnknownObj)
    External (M010, MethodObj)    // 2 Arguments
    External (M017, MethodObj)    // 6 Arguments
    External (M018, MethodObj)    // 7 Arguments
    External (M019, MethodObj)    // 4 Arguments
    External (M020, MethodObj)    // 5 Arguments
    External (M037, DeviceObj)
    External (M046, IntObj)
    External (M047, IntObj)
    External (M050, DeviceObj)
    External (M051, DeviceObj)
    External (M052, DeviceObj)
    External (M053, DeviceObj)
    External (M054, DeviceObj)
    External (M055, DeviceObj)
    External (M056, DeviceObj)
    External (M057, DeviceObj)
    External (M058, DeviceObj)
    External (M059, DeviceObj)
    External (M062, DeviceObj)
    External (M068, DeviceObj)
    External (M069, DeviceObj)
    External (M070, DeviceObj)
    External (M071, DeviceObj)
    External (M072, DeviceObj)
    External (M074, DeviceObj)
    External (M075, DeviceObj)
    External (M076, DeviceObj)
    External (M077, DeviceObj)
    External (M078, DeviceObj)
    External (M079, DeviceObj)
    External (M080, DeviceObj)
    External (M081, DeviceObj)
    External (M082, FieldUnitObj)
    External (M083, FieldUnitObj)
    External (M084, FieldUnitObj)
    External (M085, FieldUnitObj)
    External (M086, FieldUnitObj)
    External (M087, FieldUnitObj)
    External (M088, FieldUnitObj)
    External (M089, FieldUnitObj)
    External (M090, FieldUnitObj)
    External (M091, FieldUnitObj)
    External (M092, FieldUnitObj)
    External (M093, FieldUnitObj)
    External (M094, FieldUnitObj)
    External (M095, FieldUnitObj)
    External (M096, FieldUnitObj)
    External (M097, FieldUnitObj)
    External (M098, FieldUnitObj)
    External (M099, FieldUnitObj)
    External (M100, FieldUnitObj)
    External (M101, FieldUnitObj)
    External (M102, FieldUnitObj)
    External (M103, FieldUnitObj)
    External (M104, FieldUnitObj)
    External (M105, FieldUnitObj)
    External (M106, FieldUnitObj)
    External (M107, FieldUnitObj)
    External (M108, FieldUnitObj)
    External (M109, FieldUnitObj)
    External (M110, FieldUnitObj)
    External (M115, BuffObj)
    External (M116, BuffFieldObj)
    External (M117, BuffFieldObj)
    External (M118, BuffFieldObj)
    External (M119, BuffFieldObj)
    External (M120, BuffFieldObj)
    External (M122, FieldUnitObj)
    External (M127, DeviceObj)
    External (M128, FieldUnitObj)
    External (M131, FieldUnitObj)
    External (M132, FieldUnitObj)
    External (M133, FieldUnitObj)
    External (M134, FieldUnitObj)
    External (M135, FieldUnitObj)
    External (M136, FieldUnitObj)
    External (M220, FieldUnitObj)
    External (M221, FieldUnitObj)
    External (M226, FieldUnitObj)
    External (M227, DeviceObj)
    External (M229, FieldUnitObj)
    External (M231, FieldUnitObj)
    External (M233, FieldUnitObj)
    External (M235, FieldUnitObj)
    External (M23A, FieldUnitObj)
    External (M251, FieldUnitObj)
    External (M280, FieldUnitObj)
    External (M290, FieldUnitObj)
    External (M29A, FieldUnitObj)
    External (M310, FieldUnitObj)
    External (M31C, FieldUnitObj)
    External (M320, FieldUnitObj)
    External (M321, FieldUnitObj)
    External (M322, FieldUnitObj)
    External (M323, FieldUnitObj)
    External (M324, FieldUnitObj)
    External (M325, FieldUnitObj)
    External (M326, FieldUnitObj)
    External (M327, FieldUnitObj)
    External (M328, FieldUnitObj)
    External (M329, DeviceObj)
    External (M32A, DeviceObj)
    External (M32B, DeviceObj)
    External (M32C, DeviceObj)
    External (M330, DeviceObj)
    External (M331, FieldUnitObj)
    External (M378, FieldUnitObj)
    External (M379, FieldUnitObj)
    External (M380, FieldUnitObj)
    External (M381, FieldUnitObj)
    External (M382, FieldUnitObj)
    External (M383, FieldUnitObj)
    External (M384, FieldUnitObj)
    External (M385, FieldUnitObj)
    External (M386, FieldUnitObj)
    External (M387, FieldUnitObj)
    External (M388, FieldUnitObj)
    External (M389, FieldUnitObj)
    External (M390, FieldUnitObj)
    External (M391, FieldUnitObj)
    External (M392, FieldUnitObj)
    External (M404, BuffObj)
    External (M408, MutexObj)
    External (M414, FieldUnitObj)
    External (M444, FieldUnitObj)
    External (M449, FieldUnitObj)
    External (M453, FieldUnitObj)
    External (M454, FieldUnitObj)
    External (M455, FieldUnitObj)
    External (M456, FieldUnitObj)
    External (M457, FieldUnitObj)
    External (M460, MethodObj)    // 7 Arguments
    External (M4C0, FieldUnitObj)
    External (M4F0, FieldUnitObj)
    External (M601, MethodObj)    // 6 Arguments
    External (M602, MethodObj)    // 3 Arguments
    External (M610, FieldUnitObj)
    External (M620, FieldUnitObj)
    External (M631, FieldUnitObj)
    External (M652, FieldUnitObj)
    External (MPTS, MethodObj)    // 1 Arguments
    External (MWAK, MethodObj)    // 1 Arguments

    Name (PEBL, 0x10000000)
    Name (NBTS, 0x5000)
    Name (CPVD, One)
    Name (SMBB, 0x0B20)
    Name (SMBL, 0x20)
    Name (SMB0, 0x0B00)
    Name (SMBM, 0x10)
    Name (PMBS, 0x0800)
    Name (PMLN, 0xA0)
    Name (SMIO, 0xB2)
    Name (APCB, 0xFEC00000)
    Name (APCL, 0x1000)
    Name (HPTB, 0xFED00000)
    Name (WDTB, Zero)
    Name (WDTL, Zero)
    Name (GIOB, 0xFED81500)
    Name (IOMB, 0xFED80D00)
    Name (SSMB, 0xFED80200)
    Name (UTDB, Zero)
    Name (PWEN, 0x09)
    Name (REST, 0x28)
    Name (PWOK, Zero)
    Name (IOBS, Zero)
    Name (IOB2, Zero)
    Name (ATAA, 0x63)
    Name (ASSB, Zero)
    Name (AOTB, Zero)
    Name (AAXB, Zero)
    Name (PEHP, One)
    Name (SHPC, One)
    Name (PECS, One)
    Name (ITKE, Zero)
    Name (PEBS, 0xE0000000)
    Name (PELN, 0x10000000)
    Name (CSMI, 0x61)
    Name (DSSP, Zero)
    Name (FHPP, One)
    Name (SMIA, 0xB2)
    Name (OFST, 0x35)
    Name (TRST, 0x02)
    Name (TCMF, Zero)
    Name (TMF1, Zero)
    Name (TTPF, Zero)
    Name (DTPT, Zero)
    Name (TTDP, One)
    Name (TPMB, 0xFFFFFFFF)
    Name (TPBS, 0x1000)
    Name (TPMC, 0xFFFFFFFF)
    Name (TPCS, 0x1000)
    Name (TPMM, 0xFED40000)
    Name (FTPM, 0xFFFFFFFF)
    Name (PPIM, 0x89817D18)
    Name (PPIL, 0x1C)
    Name (TPMF, One)
    Name (PPIV, One)
    Name (AMDT, 0x02)
    Name (MBEC, Zero)
    Name (NBTP, 0xFEC00000)
    Name (PEER, Zero)
    Name (NDCS, 0xED)
    Name (WMIX, 0xE4)
    Name (WPVT, Zero)
    Name (PIOS, 0x00201901)
    Name (SMIP, 0xB2)
    Name (PEPM, One)
    Name (FIRT, One)
    Name (LBAL, 0x0A)
    Name (CBAL, 0x05)
    Name (RBAL, 0x08)
    Name (SLPF, One)
    Name (NVDE, Zero)
    Method (_PIC, 1, NotSerialized)  // _PIC: Interrupt Model
    {
        If (Arg0)
        {
            \_SB.DSPI ()
            \_SB.PCI0.NAPE ()
        }

        PXXX (Arg0)
    }

    OperationRegion (DEB0, SystemIO, 0x80, 0x04)
    Field (DEB0, DWordAcc, NoLock, Preserve)
    {
        DBG8,   32
    }

    Name (PICM, Zero)
    Method (PXXX, 1, NotSerialized)
    {
        If (Arg0)
        {
            DBGX = 0xAA
        }
        Else
        {
            DBGX = 0xAC
        }

        PICM = Arg0
    }

    Name (OSVR, Ones)
    Method (OSFL, 0, NotSerialized)
    {
        If ((OSVR != Ones))
        {
            Return (OSVR) /* \OSVR */
        }

        If ((PICM == Zero))
        {
            DBGX = 0xAC
        }

        OSVR = 0x03
        If (CondRefOf (\_OSI))
        {
            If (_OSI ("Windows 2001"))
            {
                OSVR = 0x04
            }

            If (_OSI ("Windows 2001.1"))
            {
                OSVR = 0x05
            }

            If (_OSI ("FreeBSD"))
            {
                OSVR = 0x06
            }

            If (_OSI ("HP-UX"))
            {
                OSVR = 0x07
            }

            If (_OSI ("OpenVMS"))
            {
                OSVR = 0x08
            }

            If (_OSI ("Windows 2001 SP1"))
            {
                OSVR = 0x09
            }

            If (_OSI ("Windows 2001 SP2"))
            {
                OSVR = 0x0A
            }

            If (_OSI ("Windows 2001 SP3"))
            {
                OSVR = 0x0B
            }

            If (_OSI ("Windows 2006"))
            {
                OSVR = 0x0C
            }

            If (_OSI ("Windows 2006 SP1"))
            {
                OSVR = 0x0D
            }

            If (_OSI ("Windows 2009"))
            {
                OSVR = 0x0E
            }

            If (_OSI ("Windows 2012"))
            {
                OSVR = 0x0F
            }

            If (_OSI ("Windows 2013"))
            {
                OSVR = 0x10
            }
        }
        Else
        {
            If (MCTH (_OS, "Microsoft Windows NT"))
            {
                OSVR = Zero
            }

            If (MCTH (_OS, "Microsoft Windows"))
            {
                OSVR = One
            }

            If (MCTH (_OS, "Microsoft WindowsME: Millennium Edition"))
            {
                OSVR = 0x02
            }

            If (MCTH (_OS, "Linux"))
            {
                OSVR = 0x03
            }

            If (MCTH (_OS, "FreeBSD"))
            {
                OSVR = 0x06
            }

            If (MCTH (_OS, "HP-UX"))
            {
                OSVR = 0x07
            }

            If (MCTH (_OS, "OpenVMS"))
            {
                OSVR = 0x08
            }
        }

        Return (OSVR) /* \OSVR */
    }

    Method (MCTH, 2, NotSerialized)
    {
        If ((SizeOf (Arg0) < SizeOf (Arg1)))
        {
            Return (Zero)
        }

        Local0 = (SizeOf (Arg0) + One)
        Name (BUF0, Buffer (Local0){})
        Name (BUF1, Buffer (Local0){})
        BUF0 = Arg0
        BUF1 = Arg1
        While (Local0)
        {
            Local0--
            If ((DerefOf (BUF0 [Local0]) != DerefOf (BUF1 [Local0]
                )))
            {
                Return (Zero)
            }
        }

        Return (One)
    }

    Name (PRWP, Package (0x02)
    {
        Zero, 
        Zero
    })
    Method (GPRW, 2, NotSerialized)
    {
        PRWP [Zero] = Arg0
        Local0 = (SS1 << One)
        Local0 |= (SS2 << 0x02)
        Local0 |= (SS3 << 0x03)
        Local0 |= (SS4 << 0x04)
        If (((One << Arg1) & Local0))
        {
            PRWP [One] = Arg1
        }
        Else
        {
            Local0 >>= One
            If (((OSFL () == One) || (OSFL () == 0x02)))
            {
                FindSetLeftBit (Local0, PRWP [One])
            }
            Else
            {
                FindSetRightBit (Local0, PRWP [One])
            }
        }

        If ((CNSB == One))
        {
            If ((Arg1 <= 0x03))
            {
                PRWP [One] = Zero
            }
        }

        Return (PRWP) /* \PRWP */
    }

    Name (WAKP, Package (0x02)
    {
        Zero, 
        Zero
    })
    Method (UPWP, 1, NotSerialized)
    {
        If (DerefOf (WAKP [Zero]))
        {
            WAKP [One] = Zero
        }
        Else
        {
            WAKP [One] = Arg0
        }
    }

    OperationRegion (DEB3, SystemIO, 0x80, One)
    Field (DEB3, ByteAcc, NoLock, Preserve)
    {
        DBGX,   8
    }

    OperationRegion (DEB1, SystemIO, 0x90, 0x02)
    Field (DEB1, WordAcc, NoLock, Preserve)
    {
        DBG9,   16
    }

    Name (SS1, Zero)
    Name (SS2, Zero)
    Name (SS3, Zero)
    Name (SS4, One)
    Name (IOST, 0xFFFF)
    Name (TOPM, 0x00000000)
    Name (ROMS, 0xFFE00000)
    Name (VGAF, One)
    OperationRegion (EXBU, SystemMemory, 0x89818018, 0x1008)
    Field (EXBU, AnyAcc, Lock, Preserve)
    {
    }

    Scope (_SB)
    {
        Name (PRSA, Buffer (0x06)
        {
             0x23, 0x70, 0xCC, 0x18, 0x79, 0x00               // #p..y.
        })
        Alias (PRSA, PRSB)
        Alias (PRSA, PRSC)
        Alias (PRSA, PRSD)
        Alias (PRSA, PRSE)
        Alias (PRSA, PRSF)
        Alias (PRSA, PRSG)
        Alias (PRSA, PRSH)
        Name (PD01, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKB, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKD, , 
                Zero
            }
        })
        Name (AR01, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x18
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x19
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x1A
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x1B
            }
        })
        Name (PD41, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKF, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKH, , 
                Zero
            }
        })
        Name (AR41, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x1C
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x1D
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x1E
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x1F
            }
        })
        Name (PD81, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKB, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKD, , 
                Zero
            }
        })
        Name (AR81, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x20
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x21
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x22
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x23
            }
        })
        Name (PDC1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKF, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKH, , 
                Zero
            }
        })
        Name (ARC1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x24
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x25
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x26
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x27
            }
        })
        Name (PDC5, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKB, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKD, , 
                Zero
            }
        })
        Name (ARC5, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x28
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x29
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x2A
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x2B
            }
        })
        Name (PDC9, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKF, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKH, , 
                Zero
            }
        })
        Name (ARC9, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x2C
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x2D
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x2E
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x2F
            }
        })
        Name (PDCD, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKF, , 
                Zero
            }
        })
        Name (ARCD, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x2E
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x2F
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x2C
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x2D
            }
        })
        Name (PDD1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKD, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKB, , 
                Zero
            }
        })
        Name (ARD1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x2A
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x2B
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x28
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x29
            }
        })
        Name (PDD5, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKF, , 
                Zero
            }
        })
        Name (ARD5, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x26
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x27
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x24
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x25
            }
        })
        Name (PDD9, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKD, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKB, , 
                Zero
            }
        })
        Name (ARD9, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x22
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x23
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x20
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x21
            }
        })
        Name (PDDD, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKF, , 
                Zero
            }
        })
        Name (ARDD, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x1E
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x1F
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x1C
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x1D
            }
        })
        Name (PDE1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKD, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKB, , 
                Zero
            }
        })
        Name (ARE1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x1A
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x1B
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x18
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x19
            }
        })
        Name (PDE5, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKB, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKD, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKA, , 
                Zero
            }
        })
        Name (ARE5, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x19
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x1A
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x1B
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x18
            }
        })
        Name (PDE9, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKF, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKE, , 
                Zero
            }
        })
        Name (ARE9, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x1D
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x1E
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x1F
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x1C
            }
        })
        Name (PDED, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKB, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKD, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKA, , 
                Zero
            }
        })
        Name (ARED, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x21
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x22
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x23
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x20
            }
        })
        Name (PDF1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKF, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKG, , 
                Zero
            }
        })
        Name (ARF1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x27
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x24
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x25
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x26
            }
        })
        Name (PDF5, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKD, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKB, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKC, , 
                Zero
            }
        })
        Name (ARF5, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x2B
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x28
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x29
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x2A
            }
        })
        Name (PDF9, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKF, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKG, , 
                Zero
            }
        })
        Name (ARF9, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x2F
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x2C
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x2D
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x2E
            }
        })
        Name (PD00, Package (0x04)
        {
            Package (0x04)
            {
                0x0014FFFF, 
                Zero, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                One, 
                LNKB, , 
                Zero
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x02, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x03, 
                LNKD, , 
                Zero
            }
        })
        Name (ARXX, Package (0x04)
        {
            Package (0x04)
            {
                0x0014FFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x03, 
                Zero, 
                0x13
            }
        })
    }

    Scope (_SB)
    {
        Device (PCI0)
        {
            Name (_HID, EisaId ("PNP0A08") /* PCI Express Bus */)  // _HID: Hardware ID
            Name (_CID, EisaId ("PNP0A03") /* PCI Bus */)  // _CID: Compatible ID
            Name (_ADR, Zero)  // _ADR: Address
            Method (^BN00, 0, NotSerialized)
            {
                Return (Zero)
            }

            Method (_BBN, 0, NotSerialized)  // _BBN: BIOS Bus Number
            {
                Return (BN00 ())
            }

            Name (_UID, Zero)  // _UID: Unique ID
            Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
            {
                If (PICM)
                {
                    Return (AR00) /* \_SB_.PCI0.AR00 */
                }

                Return (PD00) /* \_SB_.PD00 */
            }

            Method (NPTS, 1, NotSerialized)
            {
                APTS (Arg0)
            }

            Method (NWAK, 1, NotSerialized)
            {
                AWAK (Arg0)
            }

            Name (CPRB, One)
            Name (LVGA, 0x01)
            Name (STAV, 0x0F)
            Name (BRB, 0x0000)
            Name (BRL, 0x0100)
            Name (IOB, 0x1000)
            Name (IOL, 0xF000)
            Name (MBB, 0xA0000000)
            Name (MBL, 0x63F00000)
            Name (MAB, 0x0000000860000000)
            Name (MAL, 0x00000077A0000000)
            Name (MAM, 0x0000007FFFFFFFFF)
            Name (NRSB, 0x8981A000)
            OperationRegion (NRSV, SystemMemory, NRSB, 0x1000)
            Field (NRSV, AnyAcc, NoLock, Preserve)
            {
                RSTE,   32, 
                Offset (0x08), 
                Offset (0x10), 
                RSB0,   32, 
                Offset (0x18), 
                RSS0,   32, 
                Offset (0x20), 
                RSB1,   32, 
                Offset (0x28), 
                RSS1,   32, 
                Offset (0x30), 
                RSB2,   32, 
                Offset (0x38), 
                RSS2,   32, 
                Offset (0x40), 
                RSB3,   32, 
                Offset (0x48), 
                RSS3,   32, 
                Offset (0x50)
            }

            Name (CRS1, Buffer (0x0124)
            {
                /* 0000 */  0x88, 0x0D, 0x00, 0x02, 0x0C, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x00, 0x00, 0x7F, 0x00, 0x00, 0x00, 0x80, 0x00,  // ........
                /* 0010 */  0x47, 0x01, 0xF8, 0x0C, 0xF8, 0x0C, 0x01, 0x08,  // G.......
                /* 0018 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0020 */  0x00, 0x00, 0xAF, 0x03, 0x00, 0x00, 0xB0, 0x03,  // ........
                /* 0028 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0030 */  0xE0, 0x03, 0xF7, 0x0C, 0x00, 0x00, 0x18, 0x09,  // ........
                /* 0038 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0040 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0048 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0050 */  0x00, 0x0D, 0xFF, 0x0F, 0x00, 0x00, 0x00, 0x03,  // ........
                /* 0058 */  0x87, 0x17, 0x00, 0x00, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0060 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0068 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0070 */  0x00, 0x00, 0x87, 0x17, 0x00, 0x00, 0x0C, 0x01,  // ........
                /* 0078 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0C, 0x00,  // ........
                /* 0080 */  0xFF, 0xFF, 0x0D, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0088 */  0x00, 0x00, 0x02, 0x00, 0x87, 0x17, 0x00, 0x00,  // ........
                /* 0090 */  0x0C, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0098 */  0x00, 0x02, 0xFF, 0xFF, 0xDF, 0xFF, 0x00, 0x00,  // ........
                /* 00A0 */  0x00, 0x00, 0x00, 0x00, 0xE0, 0xFD, 0x87, 0x17,  // ........
                /* 00A8 */  0x00, 0x00, 0x0C, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00B0 */  0x00, 0x00, 0x00, 0x02, 0xFF, 0xFF, 0xDF, 0xFF,  // ........
                /* 00B8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xE0, 0xFD,  // ........
                /* 00C0 */  0x87, 0x17, 0x00, 0x00, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 00C8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00D0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00D8 */  0x00, 0x00, 0x87, 0x17, 0x00, 0x00, 0x0C, 0x03,  // ........
                /* 00E0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00E8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00F0 */  0x00, 0x00, 0x00, 0x00, 0x8A, 0x2B, 0x00, 0x00,  // .....+..
                /* 00F8 */  0x0C, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0100 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0108 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0110 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0118 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0120 */  0x00, 0x00, 0x79, 0x00                           // ..y.
            })
            Name (CRS2, Buffer (0xAE)
            {
                /* 0000 */  0x88, 0x0D, 0x00, 0x02, 0x0C, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x80, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x80, 0x00,  // ........
                /* 0010 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0020 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0028 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0030 */  0x87, 0x17, 0x00, 0x00, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0038 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0040 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0048 */  0x00, 0x00, 0x87, 0x17, 0x00, 0x00, 0x0C, 0x03,  // ........
                /* 0050 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80,  // ........
                /* 0058 */  0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0060 */  0x00, 0x00, 0x00, 0x80, 0x87, 0x17, 0x00, 0x00,  // ........
                /* 0068 */  0x0C, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0070 */  0x00, 0x80, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00,  // ........
                /* 0078 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x8A, 0x2B,  // .......+
                /* 0080 */  0x00, 0x00, 0x0C, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0088 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0090 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0098 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00A0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00A8 */  0x00, 0x00, 0x00, 0x00, 0x79, 0x00               // ....y.
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (STAV) /* \_SB_.PCI0.STAV */
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                DBG8 = 0x25
                If (CPRB)
                {
                    CreateWordField (CRS1, 0x08, MIN0)
                    CreateWordField (CRS1, 0x0A, MAX0)
                    CreateWordField (CRS1, 0x0E, LEN0)
                    MIN0 = BRB /* \_SB_.PCI0.BRB_ */
                    LEN0 = BRL /* \_SB_.PCI0.BRL_ */
                    Local0 = LEN0 /* \_SB_.PCI0._CRS.LEN0 */
                    MAX0 = (MIN0 + Local0--)
                    CreateWordField (CRS1, 0x50, MIN1)
                    CreateWordField (CRS1, 0x52, MAX1)
                    CreateWordField (CRS1, 0x56, LEN1)
                    If ((IOB == 0x1000))
                    {
                        Local0 = IOL /* \_SB_.PCI0.IOL_ */
                        MAX1 = (IOB + Local0--)
                        Local0 = (MAX1 - MIN1) /* \_SB_.PCI0._CRS.MIN1 */
                        LEN1 = (Local0 + One)
                    }
                    Else
                    {
                        MIN1 = IOB /* \_SB_.PCI0.IOB_ */
                        LEN1 = IOL /* \_SB_.PCI0.IOL_ */
                        Local0 = LEN1 /* \_SB_.PCI0._CRS.LEN1 */
                        MAX1 = (MIN1 + Local0--)
                    }

                    If (((LVGA == One) || (LVGA == 0x55)))
                    {
                        If (VGAF)
                        {
                            CreateWordField (CRS1, 0x40, IMN1)
                            CreateWordField (CRS1, 0x42, IMX1)
                            CreateWordField (CRS1, 0x46, ILN1)
                            IMN1 = 0x03B0
                            IMX1 = 0x03DF
                            ILN1 = 0x30
                            CreateDWordField (CRS1, 0x62, VMN1)
                            CreateDWordField (CRS1, 0x66, VMX1)
                            CreateDWordField (CRS1, 0x6E, VLN1)
                            VMN1 = 0x000A0000
                            VMX1 = 0x000BFFFF
                            VLN1 = 0x00020000
                            VGAF = Zero
                        }
                    }

                    CreateDWordField (CRS1, 0x96, MIN3)
                    CreateDWordField (CRS1, 0x9A, MAX3)
                    CreateDWordField (CRS1, 0xA2, LEN3)
                    CreateDWordField (CRS1, 0xB0, MIN7)
                    CreateDWordField (CRS1, 0xB4, MAX7)
                    CreateDWordField (CRS1, 0xBC, LEN7)
                    CreateDWordField (CRS1, 0xCA, MIN9)
                    CreateDWordField (CRS1, 0xCE, MAX9)
                    CreateDWordField (CRS1, 0xD6, LEN9)
                    CreateDWordField (CRS1, 0xE4, MINA)
                    CreateDWordField (CRS1, 0xE8, MAXA)
                    CreateDWordField (CRS1, 0xF0, LENA)
                    Local7 = Zero
                    If ((NRSB != 0x00010000))
                    {
                        If ((RSTE == One))
                        {
                            Local7 = One
                            MIN3 = RSB0 /* \_SB_.PCI0.RSB0 */
                            LEN3 = RSS0 /* \_SB_.PCI0.RSS0 */
                            Local0 = (RSB0 + RSS0) /* \_SB_.PCI0.RSS0 */
                            If ((Local0 != Zero))
                            {
                                Local0 -= One
                            }

                            MAX3 = Local0
                            MIN7 = RSB1 /* \_SB_.PCI0.RSB1 */
                            LEN7 = RSS1 /* \_SB_.PCI0.RSS1 */
                            Local0 = (RSB1 + RSS1) /* \_SB_.PCI0.RSS1 */
                            If ((Local0 != Zero))
                            {
                                Local0 -= One
                            }

                            MAX7 = Local0
                            MIN9 = RSB2 /* \_SB_.PCI0.RSB2 */
                            LEN9 = RSS2 /* \_SB_.PCI0.RSS2 */
                            Local0 = (RSB2 + RSS2) /* \_SB_.PCI0.RSS2 */
                            If ((Local0 != Zero))
                            {
                                Local0 -= One
                            }

                            MAX9 = Local0
                            MINA = RSB3 /* \_SB_.PCI0.RSB3 */
                            LENA = RSS3 /* \_SB_.PCI0.RSS3 */
                            Local0 = (RSB3 + RSS3) /* \_SB_.PCI0.RSS3 */
                            If ((Local0 != Zero))
                            {
                                Local0 -= One
                            }

                            MAXA = Local0
                        }
                    }

                    If ((Local7 == Zero))
                    {
                        Local0 = (MBB + MBL) /* \_SB_.PCI0.MBL_ */
                        If ((Local0 < NBTP))
                        {
                            MIN3 = MBB /* \_SB_.PCI0.MBB_ */
                            LEN3 = MBL /* \_SB_.PCI0.MBL_ */
                            Local0 = LEN3 /* \_SB_.PCI0._CRS.LEN3 */
                            MAX3 = (MIN3 + Local0--)
                            MIN7 = Zero
                            MAX7 = Zero
                            LEN7 = Zero
                        }
                        Else
                        {
                            MIN3 = MBB /* \_SB_.PCI0.MBB_ */
                            LEN3 = (NBTP - MBB)
                            Local0 = LEN3 /* \_SB_.PCI0._CRS.LEN3 */
                            MAX3 = (MIN3 + Local0--)
                            If (((MBL - LEN3) < 0x00200000))
                            {
                                MIN7 = Zero
                                MAX7 = Zero
                                LEN7 = Zero
                            }
                            Else
                            {
                                MIN7 = 0xFEE00000
                                Local0 = (0xFEE00000 - NBTP)
                                LEN7 = (MBL - Local0)
                                LEN7 = (LEN7 - LEN3)
                                Local0 = LEN7 /* \_SB_.PCI0._CRS.LEN7 */
                                MAX7 = (MIN7 + Local0--)
                            }
                        }
                    }

                    If (MAL)
                    {
                        CreateQWordField (CRS1, 0x0102, MN8)
                        CreateQWordField (CRS1, 0x010A, MX8)
                        CreateQWordField (CRS1, 0x011A, LN8)
                        MN8 = MAB /* \_SB_.PCI0.MAB_ */
                        LN8 = MAL /* \_SB_.PCI0.MAL_ */
                        MX8 = MAM /* \_SB_.PCI0.MAM_ */
                    }

                    DBG8 = 0x24
                    Return (CRS1) /* \_SB_.PCI0.CRS1 */
                }
                Else
                {
                    CreateWordField (CRS2, 0x08, MIN2)
                    CreateWordField (CRS2, 0x0A, MAX2)
                    CreateWordField (CRS2, 0x0E, LEN2)
                    MIN2 = BRB /* \_SB_.PCI0.BRB_ */
                    LEN2 = BRL /* \_SB_.PCI0.BRL_ */
                    Local1 = LEN2 /* \_SB_.PCI0._CRS.LEN2 */
                    MAX2 = (MIN2 + Local1--)
                    CreateWordField (CRS2, 0x28, MIN4)
                    CreateWordField (CRS2, 0x2A, MAX4)
                    CreateWordField (CRS2, 0x2E, LEN4)
                    MIN4 = IOB /* \_SB_.PCI0.IOB_ */
                    LEN4 = IOL /* \_SB_.PCI0.IOL_ */
                    Local1 = LEN4 /* \_SB_.PCI0._CRS.LEN4 */
                    MAX4 = (MIN4 + Local1--)
                    If (LVGA)
                    {
                        CreateWordField (CRS2, 0x18, IMN2)
                        CreateWordField (CRS2, 0x1A, IMX2)
                        CreateWordField (CRS2, 0x1E, ILN2)
                        IMN2 = 0x03B0
                        IMX2 = 0x03DF
                        ILN2 = 0x30
                        CreateDWordField (CRS2, 0x3A, VMN2)
                        CreateDWordField (CRS2, 0x3E, VMX2)
                        CreateDWordField (CRS2, 0x46, VLN2)
                        VMN2 = 0x000A0000
                        VMX2 = 0x000BFFFF
                        VLN2 = 0x00020000
                    }

                    CreateDWordField (CRS2, 0x54, MIN5)
                    CreateDWordField (CRS2, 0x58, MAX5)
                    CreateDWordField (CRS2, 0x60, LEN5)
                    MIN5 = MBB /* \_SB_.PCI0.MBB_ */
                    LEN5 = (NBTP - MBB)
                    Local1 = LEN5 /* \_SB_.PCI0._CRS.LEN5 */
                    MAX5 = (MIN5 + Local1--)
                    CreateDWordField (CRS2, 0x6E, MIN6)
                    CreateDWordField (CRS2, 0x72, MAX6)
                    CreateDWordField (CRS2, 0x7A, LEN6)
                    MIN6 = (NBTP + NBTS) /* \NBTS */
                    LEN6 = (MBL - NBTS)
                    LEN6 = (LEN6 - LEN5)
                    Local0 = LEN6 /* \_SB_.PCI0._CRS.LEN6 */
                    MAX6 = (MIN6 + Local0--)
                    If (MAL)
                    {
                        CreateQWordField (CRS2, 0x8C, MN9)
                        CreateQWordField (CRS2, 0x94, MX9)
                        CreateQWordField (CRS2, 0xA4, LN9)
                        MN9 = MAB /* \_SB_.PCI0.MAB_ */
                        LN9 = MAL /* \_SB_.PCI0.MAL_ */
                        MX9 = MAM /* \_SB_.PCI0.MAM_ */
                    }

                    DBG8 = 0x23
                    Return (CRS2) /* \_SB_.PCI0.CRS2 */
                }
            }

            Method (_OSC, 4, Serialized)  // _OSC: Operating System Capabilities
            {
                Name (SUPP, Zero)
                Name (CTRL, Zero)
                CreateDWordField (Arg3, Zero, CDW1)
                CreateDWordField (Arg3, 0x04, CDW2)
                CreateDWordField (Arg3, 0x08, CDW3)
                If ((Arg0 == ToUUID ("33db4d5b-1ff7-401c-9657-7441c03dd766") /* PCI Host Bridge Device */))
                {
                    SUPP = CDW2 /* \_SB_.PCI0._OSC.CDW2 */
                    CTRL = CDW3 /* \_SB_.PCI0._OSC.CDW3 */
                    If (((SUPP & 0x16) != 0x16))
                    {
                        CTRL &= 0x1E
                    }

                    If (!PEHP)
                    {
                        CTRL &= 0x1E
                    }

                    If (!SHPC)
                    {
                        CTRL &= 0x1D
                    }

                    If (!PEPM)
                    {
                        CTRL &= 0x1B
                    }

                    If (!PEER)
                    {
                        CTRL &= 0x15
                    }

                    If (!PECS)
                    {
                        CTRL &= 0x0F
                    }

                    If ((Arg1 != One))
                    {
                        CDW1 |= 0x08
                    }

                    If ((CDW3 != CTRL))
                    {
                        CDW1 |= 0x10
                    }

                    CDW3 = CTRL /* \_SB_.PCI0._OSC.CTRL */
                    Return (Arg3)
                }
                Else
                {
                    CDW1 |= 0x04
                    Return (Arg3)
                }
            }

            Mutex (NAPM, 0x00)
            Method (NAPE, 0, NotSerialized)
            {
                Acquire (NAPM, 0xFFFF)
                DBG8 = 0x11
                Local0 = (PEBS + 0xB8)
                OperationRegion (VARM, SystemMemory, Local0, 0x08)
                Field (VARM, DWordAcc, NoLock, Preserve)
                {
                    NAPX,   32, 
                    NAPD,   32
                }

                Local1 = NAPX /* \_SB_.PCI0.NAPE.NAPX */
                NAPX = 0x14300000
                Local0 = NAPD /* \_SB_.PCI0.NAPE.NAPD */
                Local0 &= 0xFFFFFFEF
                NAPD = Local0
                NAPX = Local1
                DBG8 = 0x12
                Release (NAPM)
            }

            Device (IOMA)
            {
                Name (_ADR, 0x02)  // _ADR: Address
            }

            Device (SBRG)
            {
                Name (_ADR, 0x00140003)  // _ADR: Address
                OperationRegion (SMI0, SystemIO, SMIO, One)
                Field (SMI0, ByteAcc, NoLock, Preserve)
                {
                    SMIC,   8
                }

                Scope (\_SB)
                {
                    Scope (PCI0)
                    {
                        Device (S900)
                        {
                            Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                            Name (_UID, 0x0700)  // _UID: Unique ID
                            Name (_STA, 0x0F)  // _STA: Status
                            Name (CRS, Buffer (0x017A)
                            {
                                /* 0000 */  0x47, 0x01, 0x10, 0x00, 0x10, 0x00, 0x00, 0x10,  // G.......
                                /* 0008 */  0x47, 0x01, 0x22, 0x00, 0x22, 0x00, 0x00, 0x1E,  // G."."...
                                /* 0010 */  0x47, 0x01, 0x63, 0x00, 0x63, 0x00, 0x00, 0x01,  // G.c.c...
                                /* 0018 */  0x47, 0x01, 0x65, 0x00, 0x65, 0x00, 0x00, 0x01,  // G.e.e...
                                /* 0020 */  0x47, 0x01, 0x67, 0x00, 0x67, 0x00, 0x00, 0x09,  // G.g.g...
                                /* 0028 */  0x47, 0x01, 0x72, 0x00, 0x72, 0x00, 0x00, 0x0E,  // G.r.r...
                                /* 0030 */  0x47, 0x01, 0x80, 0x00, 0x80, 0x00, 0x00, 0x01,  // G.......
                                /* 0038 */  0x47, 0x01, 0x84, 0x00, 0x84, 0x00, 0x00, 0x03,  // G.......
                                /* 0040 */  0x47, 0x01, 0x88, 0x00, 0x88, 0x00, 0x00, 0x01,  // G.......
                                /* 0048 */  0x47, 0x01, 0x8C, 0x00, 0x8C, 0x00, 0x00, 0x03,  // G.......
                                /* 0050 */  0x47, 0x01, 0x90, 0x00, 0x90, 0x00, 0x00, 0x10,  // G.......
                                /* 0058 */  0x47, 0x01, 0xA2, 0x00, 0xA2, 0x00, 0x00, 0x1E,  // G.......
                                /* 0060 */  0x47, 0x01, 0xB1, 0x00, 0xB1, 0x00, 0x00, 0x01,  // G.......
                                /* 0068 */  0x47, 0x01, 0xE0, 0x00, 0xE0, 0x00, 0x00, 0x10,  // G.......
                                /* 0070 */  0x47, 0x01, 0xD0, 0x04, 0xD0, 0x04, 0x00, 0x02,  // G.......
                                /* 0078 */  0x47, 0x01, 0x0B, 0x04, 0x0B, 0x04, 0x00, 0x01,  // G.......
                                /* 0080 */  0x47, 0x01, 0xD6, 0x04, 0xD6, 0x04, 0x00, 0x01,  // G.......
                                /* 0088 */  0x47, 0x01, 0x00, 0x0C, 0x00, 0x0C, 0x00, 0x02,  // G.......
                                /* 0090 */  0x47, 0x01, 0x14, 0x0C, 0x14, 0x0C, 0x00, 0x01,  // G.......
                                /* 0098 */  0x47, 0x01, 0x50, 0x0C, 0x50, 0x0C, 0x00, 0x02,  // G.P.P...
                                /* 00A0 */  0x47, 0x01, 0x52, 0x0C, 0x52, 0x0C, 0x00, 0x01,  // G.R.R...
                                /* 00A8 */  0x47, 0x01, 0x6C, 0x0C, 0x6C, 0x0C, 0x00, 0x01,  // G.l.l...
                                /* 00B0 */  0x47, 0x01, 0x6F, 0x0C, 0x6F, 0x0C, 0x00, 0x01,  // G.o.o...
                                /* 00B8 */  0x47, 0x01, 0xD0, 0x0C, 0xD0, 0x0C, 0x00, 0x02,  // G.......
                                /* 00C0 */  0x47, 0x01, 0xD2, 0x0C, 0xD2, 0x0C, 0x00, 0x02,  // G.......
                                /* 00C8 */  0x47, 0x01, 0xD4, 0x0C, 0xD4, 0x0C, 0x00, 0x02,  // G.......
                                /* 00D0 */  0x47, 0x01, 0xD6, 0x0C, 0xD6, 0x0C, 0x00, 0x02,  // G.......
                                /* 00D8 */  0x47, 0x01, 0xD8, 0x0C, 0xD8, 0x0C, 0x00, 0x08,  // G.......
                                /* 00E0 */  0x47, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // G.......
                                /* 00E8 */  0x47, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // G.......
                                /* 00F0 */  0x47, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // G.......
                                /* 00F8 */  0x47, 0x01, 0x00, 0x09, 0x00, 0x09, 0x00, 0x10,  // G.......
                                /* 0100 */  0x47, 0x01, 0x10, 0x09, 0x10, 0x09, 0x00, 0x10,  // G.......
                                /* 0108 */  0x47, 0x01, 0x60, 0x00, 0x60, 0x00, 0x00, 0x00,  // G.`.`...
                                /* 0110 */  0x47, 0x01, 0x64, 0x00, 0x64, 0x00, 0x00, 0x00,  // G.d.d...
                                /* 0118 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0120 */  0x00, 0x00, 0x00, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                                /* 0128 */  0x00, 0x10, 0xC0, 0xFE, 0x00, 0x10, 0x00, 0x00,  // ........
                                /* 0130 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xDC, 0xFE,  // ........
                                /* 0138 */  0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                                /* 0140 */  0x00, 0x00, 0xE0, 0xFE, 0x00, 0x10, 0x00, 0x00,  // ........
                                /* 0148 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xD8, 0xFE,  // ........
                                /* 0150 */  0x00, 0x00, 0x01, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                                /* 0158 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0160 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0168 */  0x00, 0x00, 0x00, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                                /* 0170 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0178 */  0x79, 0x00                                       // y.
                            })
                            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                            {
                                CreateWordField (CRS, 0xE2, PBB)
                                CreateWordField (CRS, 0xE4, PBH)
                                CreateByteField (CRS, 0xE7, PML)
                                PBB = PMBS /* \PMBS */
                                PBH = PMBS /* \PMBS */
                                PML = PMLN /* \PMLN */
                                If (SMBB)
                                {
                                    CreateWordField (CRS, 0xF2, SMB1)
                                    CreateWordField (CRS, 0xF4, SMH1)
                                    CreateByteField (CRS, 0xF7, SML1)
                                    SMB1 = SMBB /* \SMBB */
                                    SMH1 = SMBB /* \SMBB */
                                    SML1 = SMBL /* \SMBL */
                                    CreateWordField (CRS, 0xEA, SMBZ)
                                    CreateWordField (CRS, 0xEC, SMH0)
                                    CreateByteField (CRS, 0xEF, SML0)
                                    SMBZ = SMB0 /* \SMB0 */
                                    SMH0 = SMB0 /* \SMB0 */
                                    SML0 = SMBM /* \SMBM */
                                }

                                If (APCB)
                                {
                                    CreateDWordField (CRS, 0x011C, APB)
                                    CreateDWordField (CRS, 0x0120, APL)
                                    APB = APCB /* \APCB */
                                    APL = APCL /* \APCL */
                                }

                                CreateDWordField (CRS, 0x0158, SPIB)
                                CreateDWordField (CRS, 0x015C, SPIL)
                                SPIB = 0xFEC10000
                                SPIL = 0x1000
                                If (WDTB)
                                {
                                    CreateDWordField (CRS, 0x0164, WDTB)
                                    CreateDWordField (CRS, 0x0168, WDTL)
                                    WDTB = \WDTB
                                    WDTL = \WDTL
                                }

                                CreateDWordField (CRS, 0x0170, ROMB)
                                CreateDWordField (CRS, 0x0174, ROML)
                                ROMB = 0xFF000000
                                ROML = 0x01000000
                                Return (CRS) /* \_SB_.PCI0.S900.CRS_ */
                            }
                        }
                    }
                }

                Scope (\_SB)
                {
                    Scope (PCI0)
                    {
                        Scope (SBRG)
                        {
                            Method (RRIO, 4, NotSerialized)
                            {
                                Debug = "RRIO"
                            }

                            Method (RDMA, 3, NotSerialized)
                            {
                                Debug = "rDMA"
                            }
                        }
                    }
                }
            }

            Device (D034)
            {
                Name (_ADR, 0x00140006)  // _ADR: Address
            }
        }
    }

    Name (_S0, Package (0x04)  // _S0_: S0 System State
    {
        Zero, 
        Zero, 
        Zero, 
        Zero
    })
    Name (XS3, Package (0x04)
    {
        0x03, 
        Zero, 
        Zero, 
        Zero
    })
    Name (_S4, Package (0x04)  // _S4_: S4 System State
    {
        0x04, 
        Zero, 
        Zero, 
        Zero
    })
    Name (_S5, Package (0x04)  // _S5_: S5 System State
    {
        0x05, 
        Zero, 
        Zero, 
        Zero
    })
    Method (_PTS, 1, NotSerialized)  // _PTS: Prepare To Sleep
    {
        If (Arg0)
        {
            PTS (Arg0)
            \_SB.TPM.TPTS (Arg0)
            MPTS (Arg0)
            SPTS (Arg0)
            \_SB.PCI0.NPTS (Arg0)
        }
    }

    Method (_WAK, 1, NotSerialized)  // _WAK: Wake
    {
        If (((Arg0 == 0x03) || (Arg0 == 0x04)))
        {
            If ((PICM != Zero))
            {
                \_SB.PCI0.NAPE ()
            }
        }

        DBG8 = (Arg0 << 0x04)
        \_SB.PCI0.NWAK (Arg0)
        DBG8 = (Arg0 << 0x04)
        SWAK (Arg0)
        MWAK (Arg0)
        If ((Arg0 == 0x04))
        {
            PT80 (0xE4)
            If ((\_SB.APBM == One))
            {
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }
        }

        WAK (Arg0)
        Return (WAKP) /* \WAKP */
    }

    Scope (_SB)
    {
        OperationRegion (PIRQ, SystemIO, 0x0C00, 0x02)
        Field (PIRQ, ByteAcc, NoLock, Preserve)
        {
            PIDX,   8, 
            PDAT,   8
        }

        IndexField (PIDX, PDAT, ByteAcc, NoLock, Preserve)
        {
            PIRA,   8, 
            PIRB,   8, 
            PIRC,   8, 
            PIRD,   8, 
            PIRE,   8, 
            PIRF,   8, 
            PIRG,   8, 
            PIRH,   8, 
            Offset (0x0C), 
            SIRA,   8, 
            SIRB,   8, 
            SIRC,   8, 
            SIRD,   8, 
            PIRS,   8, 
            Offset (0x13), 
            HDAD,   8, 
            Offset (0x17), 
            SDCL,   8, 
            Offset (0x1A), 
            SDIO,   8, 
            Offset (0x30), 
            USB1,   8, 
            Offset (0x34), 
            USB3,   8, 
            Offset (0x41), 
            SATA,   8, 
            Offset (0x62), 
            GIOC,   8, 
            Offset (0x70), 
            I2C0,   8, 
            I2C1,   8, 
            I2C2,   8, 
            I2C3,   8, 
            URT0,   8, 
            URT1,   8, 
            Offset (0x80), 
            AIRA,   8, 
            AIRB,   8, 
            AIRC,   8, 
            AIRD,   8, 
            AIRE,   8, 
            AIRF,   8, 
            AIRG,   8, 
            AIRH,   8
        }

        OperationRegion (KBDD, SystemIO, 0x64, One)
        Field (KBDD, ByteAcc, NoLock, Preserve)
        {
            PD64,   8
        }

        Method (DSPI, 0, NotSerialized)
        {
            INTA (0x1F)
            INTB (0x1F)
            INTC (0x1F)
            INTD (0x1F)
            Local1 = PD64 /* \_SB_.PD64 */
            PIRE = 0x1F
            PIRF = 0x1F
            PIRG = 0x1F
            PIRH = 0x1F
            Local1 = PD64 /* \_SB_.PD64 */
            AIRA = 0x10
            AIRB = 0x11
            AIRC = 0x12
            AIRD = 0x13
            AIRE = 0x14
            AIRF = 0x15
            AIRG = 0x16
            AIRH = 0x17
        }

        Method (INTA, 1, NotSerialized)
        {
            PIRA = Arg0
            HDAD = Arg0
        }

        Method (INTB, 1, NotSerialized)
        {
            PIRB = Arg0
        }

        Method (INTC, 1, NotSerialized)
        {
            PIRC = Arg0
            USB1 = Arg0
            USB3 = Arg0
        }

        Method (INTD, 1, NotSerialized)
        {
            PIRD = Arg0
            SATA = Arg0
        }

        Name (BUFA, Buffer (0x06)
        {
             0x23, 0x00, 0x80, 0x18, 0x79, 0x00               // #...y.
        })
        Name (IPRA, Buffer (0x06)
        {
             0x23, 0x20, 0x0C, 0x18, 0x79, 0x00               // # ..y.
        })
        Name (IPRB, Buffer (0x06)
        {
             0x23, 0x20, 0x0C, 0x18, 0x79, 0x00               // # ..y.
        })
        Name (IPRC, Buffer (0x06)
        {
             0x23, 0x20, 0x0C, 0x18, 0x79, 0x00               // # ..y.
        })
        Name (IPRD, Buffer (0x06)
        {
             0x23, 0x20, 0x0C, 0x18, 0x79, 0x00               // # ..y.
        })
        Device (LNKA)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRA)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSA) /* \_SB_.PRSA */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                INTA (0x1F)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRA) /* \_SB_.PIRA */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                INTA (Local0)
            }
        }

        Device (LNKB)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRB)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSB) /* \_SB_.PRSB */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                INTB (0x1F)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRB) /* \_SB_.PIRB */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                INTB (Local0)
            }
        }

        Device (LNKC)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRC)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSC) /* \_SB_.PRSC */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                INTC (0x1F)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRC) /* \_SB_.PIRC */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                INTC (Local0)
            }
        }

        Device (LNKD)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRD)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSD) /* \_SB_.PRSD */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                INTD (0x1F)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRD) /* \_SB_.PIRD */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                INTD (Local0)
            }
        }

        Device (LNKE)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x05)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRE)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSE) /* \_SB_.PRSE */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRE = 0x1F
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRE) /* \_SB_.PIRE */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (PIRE, Local0)
                Local0--
                PIRE = Local0
            }
        }

        Device (LNKF)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x06)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRF)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSF) /* \_SB_.PRSF */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRF = 0x1F
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRF) /* \_SB_.PIRF */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRF = Local0
            }
        }

        Device (LNKG)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x07)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRG)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSG) /* \_SB_.PRSG */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRG = 0x1F
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRG) /* \_SB_.PIRG */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRG = Local0
            }
        }

        Device (LNKH)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x08)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRH)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSH) /* \_SB_.PRSH */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRH = 0x1F
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRH) /* \_SB_.PIRH */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRH = Local0
            }
        }
    }

    Name (OSTB, Ones)
    Name (TPOS, Zero)
    Name (OSSP, Zero)
    Method (SEQL, 2, Serialized)
    {
        Local0 = SizeOf (Arg0)
        Local1 = SizeOf (Arg1)
        If ((Local0 != Local1))
        {
            Return (Zero)
        }

        Name (BUF0, Buffer (Local0){})
        BUF0 = Arg0
        Name (BUF1, Buffer (Local0){})
        BUF1 = Arg1
        Local2 = Zero
        While ((Local2 < Local0))
        {
            Local3 = DerefOf (BUF0 [Local2])
            Local4 = DerefOf (BUF1 [Local2])
            If ((Local3 != Local4))
            {
                Return (Zero)
            }

            Local2++
        }

        Return (One)
    }

    Method (OSTP, 0, NotSerialized)
    {
        If ((OSTB == Ones))
        {
            If (CondRefOf (\_OSI, Local0))
            {
                OSTB = Zero
                TPOS = Zero
                If (_OSI ("Windows 2001"))
                {
                    OSTB = 0x08
                    TPOS = 0x08
                }

                If (_OSI ("Windows 2001.1"))
                {
                    OSTB = 0x20
                    TPOS = 0x20
                }

                If (_OSI ("Windows 2001 SP1"))
                {
                    OSTB = 0x10
                    TPOS = 0x10
                }

                If (_OSI ("Windows 2001 SP2"))
                {
                    OSTB = 0x11
                    TPOS = 0x11
                }

                If (_OSI ("Windows 2001 SP3"))
                {
                    OSTB = 0x12
                    TPOS = 0x12
                }

                If (_OSI ("Windows 2006"))
                {
                    OSTB = 0x40
                    TPOS = 0x40
                }

                If (_OSI ("Windows 2006 SP1"))
                {
                    OSTB = 0x41
                    TPOS = 0x41
                    OSSP = One
                }

                If (_OSI ("Windows 2009"))
                {
                    OSSP = One
                    OSTB = 0x50
                    TPOS = 0x50
                }

                If (_OSI ("Windows 2012"))
                {
                    OSSP = One
                    OSTB = 0x60
                    TPOS = 0x60
                }

                If (_OSI ("Windows 2013"))
                {
                    OSSP = One
                    OSTB = 0x61
                    TPOS = 0x61
                }

                If (_OSI ("Windows 2015"))
                {
                    OSSP = One
                    OSTB = 0x70
                    TPOS = 0x70
                }
            }
            ElseIf (CondRefOf (\_OS, Local0))
            {
                If (SEQL (_OS, "Microsoft Windows"))
                {
                    OSTB = One
                    TPOS = One
                }
                ElseIf (SEQL (_OS, "Microsoft WindowsME: Millennium Edition"))
                {
                    OSTB = 0x02
                    TPOS = 0x02
                }
                ElseIf (SEQL (_OS, "Microsoft Windows NT"))
                {
                    OSTB = 0x04
                    TPOS = 0x04
                }
                Else
                {
                    OSTB = Zero
                    TPOS = Zero
                }
            }
            Else
            {
                OSTB = Zero
                TPOS = Zero
            }
        }

        Return (OSTB) /* \OSTB */
    }

    Scope (_SB.PCI0)
    {
        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            If ((PICM != Zero))
            {
                DSPI ()
                NAPE ()
            }

            OSTP ()
            OSFL ()
        }
    }

    OperationRegion (DBG0, SystemIO, 0x80, One)
    Field (DBG0, ByteAcc, NoLock, Preserve)
    {
        IO80,   8
    }

    OperationRegion (DBG1, SystemIO, 0x80, 0x04)
    Field (DBG1, DWordAcc, NoLock, Preserve)
    {
        P80H,   32
    }

    OperationRegion (PCPT, SystemIO, 0x80, 0x04)
    Field (PCPT, DWordAcc, NoLock, Preserve)
    {
        PC80,   32
    }

    OperationRegion (PSMI, SystemIO, 0xB0, 0x02)
    Field (PSMI, ByteAcc, NoLock, Preserve)
    {
        APMC,   8, 
        APMD,   8
    }

    OperationRegion (PMI0, SystemMemory, 0xFED80300, 0x0100)
    Field (PMI0, AnyAcc, NoLock, Preserve)
    {
            ,   6, 
        HPEN,   1, 
        Offset (0x60), 
        P1EB,   16
    }

    OperationRegion (GSMG, SystemMemory, 0xFED81500, 0x03FF)
    Field (GSMG, AnyAcc, NoLock, Preserve)
    {
        Offset (0x5C), 
        Offset (0x5E), 
        GS23,   1, 
            ,   5, 
        GV23,   1, 
        GE23,   1, 
        Offset (0xA0), 
        Offset (0xA2), 
        GS40,   1, 
            ,   5, 
        GV40,   1, 
        GE40,   1
    }

    OperationRegion (GSMM, SystemMemory, 0xFED80000, 0x1000)
    Field (GSMM, AnyAcc, NoLock, Preserve)
    {
        Offset (0x288), 
            ,   1, 
        CLPS,   1, 
        Offset (0x296), 
            ,   7, 
        TMSE,   1, 
        Offset (0x2B0), 
            ,   2, 
        SLPS,   2
    }

    OperationRegion (PMI2, SystemMemory, 0xFED80300, 0x0100)
    Field (PMI2, AnyAcc, NoLock, Preserve)
    {
        Offset (0xBB), 
            ,   6, 
        PWDE,   1, 
        Offset (0xBC)
    }

    OperationRegion (P1E0, SystemIO, P1EB, 0x04)
    Field (P1E0, ByteAcc, NoLock, Preserve)
    {
            ,   14, 
        PEWS,   1, 
        WSTA,   1, 
            ,   14, 
        PEWD,   1
    }

    OperationRegion (IOCC, SystemIO, 0x0400, 0x80)
    Field (IOCC, ByteAcc, NoLock, Preserve)
    {
        Offset (0x01), 
            ,   2, 
        RTCS,   1
    }

    Name (CNSB, One)
    Name (RDHW, Zero)
    Name (TBEN, Zero)
    Name (TBNH, 0x03)
    Name (DPTC, One)
    Name (THPN, 0x05)
    Name (THPD, 0x04)
    Name (NFCS, 0x04)
    Method (PT80, 1, Serialized)
    {
        Local0 = (Arg0 & 0x00FFFFFF)
        PC80 = (Local0 | 0xDB000000)
    }

    Scope (_SB)
    {
        Name (APBM, 0x01)
        Device (PWRB)
        {
            Name (_HID, EisaId ("PNP0C0C") /* Power Button Device */)  // _HID: Hardware ID
            Name (_DDN, "Power button")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Name (PSTA, Zero)
                If ((APBM == One))
                {
                    M460 ("PLA-ASL-\\_SB.PWRB._STA = 0xB\n", Zero, Zero, Zero, Zero, Zero, Zero)
                    PSTA = 0x0B
                }

                Return (PSTA) /* \_SB_.PWRB._STA.PSTA */
            }
        }

        Device (BTNS)
        {
            Name (_HID, "ACPI0011" /* Generic Buttons Device */)  // _HID: Hardware ID
            Name (_DDN, "Generic buttons device")  // _DDN: DOS Device Name
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x25)
                {
                    /* 0000 */  0x8C, 0x20, 0x00, 0x01, 0x00, 0x01, 0x00, 0x15,  // . ......
                    /* 0008 */  0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x17, 0x00,  // ........
                    /* 0010 */  0x00, 0x19, 0x00, 0x23, 0x00, 0x00, 0x00, 0x00,  // ...#....
                    /* 0018 */  0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x47, 0x50,  // .\_SB.GP
                    /* 0020 */  0x49, 0x4F, 0x00, 0x79, 0x00                     // IO.y.
                })
                Return (RBUF) /* \_SB_.BTNS._CRS.RBUF */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Name (PSTA, Zero)
                If ((APBM == Zero))
                {
                    M460 ("PLA-ASL-\\_SB.BTNS._STA = 0xB\n", Zero, Zero, Zero, Zero, Zero, Zero)
                    PSTA = 0x0B
                }

                Return (PSTA) /* \_SB_.BTNS._STA.PSTA */
            }

            Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
            {
                ToUUID ("fa6bd625-9ce8-470d-a2c7-b3ca36c4282e") /* Generic Buttons Device */, 
                Package (0x02)
                {
                    Package (0x05)
                    {
                        Zero, 
                        One, 
                        Zero, 
                        One, 
                        0x0D
                    }, 

                    Package (0x05)
                    {
                        One, 
                        Zero, 
                        One, 
                        One, 
                        0x81
                    }
                }
            })
        }

        Device (AMDM)
        {
            Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Name (_CRS, Buffer (0x0E)  // _CRS: Current Resource Settings
            {
                /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0xE0,  // ........
                /* 0008 */  0x00, 0x00, 0x00, 0x10, 0x79, 0x00               // ....y.
            })
        }

        Scope (PCI0)
        {
            Mutex (MGCC, 0x00)
            Name (AR00, Package (0x12)
            {
                Package (0x04)
                {
                    0x0001FFFF, 
                    Zero, 
                    Zero, 
                    0x18
                }, 

                Package (0x04)
                {
                    0x0001FFFF, 
                    One, 
                    Zero, 
                    0x19
                }, 

                Package (0x04)
                {
                    0x0001FFFF, 
                    0x02, 
                    Zero, 
                    0x1A
                }, 

                Package (0x04)
                {
                    0x0002FFFF, 
                    Zero, 
                    Zero, 
                    0x1C
                }, 

                Package (0x04)
                {
                    0x0002FFFF, 
                    One, 
                    Zero, 
                    0x1D
                }, 

                Package (0x04)
                {
                    0x0002FFFF, 
                    0x02, 
                    Zero, 
                    0x1E
                }, 

                Package (0x04)
                {
                    0x0002FFFF, 
                    0x03, 
                    Zero, 
                    0x1F
                }, 

                Package (0x04)
                {
                    0x0003FFFF, 
                    Zero, 
                    Zero, 
                    0x20
                }, 

                Package (0x04)
                {
                    0x0003FFFF, 
                    One, 
                    Zero, 
                    0x21
                }, 

                Package (0x04)
                {
                    0x0003FFFF, 
                    0x02, 
                    Zero, 
                    0x22
                }, 

                Package (0x04)
                {
                    0x0003FFFF, 
                    0x03, 
                    Zero, 
                    0x23
                }, 

                Package (0x04)
                {
                    0x0008FFFF, 
                    Zero, 
                    Zero, 
                    0x24
                }, 

                Package (0x04)
                {
                    0x0008FFFF, 
                    One, 
                    Zero, 
                    0x25
                }, 

                Package (0x04)
                {
                    0x0008FFFF, 
                    0x02, 
                    Zero, 
                    0x26
                }, 

                Package (0x04)
                {
                    0x0014FFFF, 
                    Zero, 
                    Zero, 
                    0x10
                }, 

                Package (0x04)
                {
                    0x0014FFFF, 
                    One, 
                    Zero, 
                    0x11
                }, 

                Package (0x04)
                {
                    0x0014FFFF, 
                    0x02, 
                    Zero, 
                    0x12
                }, 

                Package (0x04)
                {
                    0x0014FFFF, 
                    0x03, 
                    Zero, 
                    0x13
                }
            })
            Device (GPP0)
            {
                Name (_ADR, 0x00010001)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x18
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x19
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x1A
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x1B
                    }
                })
            }

            Device (GPP1)
            {
                Name (_ADR, 0x00010002)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x1C
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x1D
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x1E
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x1F
                    }
                })
            }

            Device (GPP3)
            {
                Name (_ADR, 0x00020001)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x24
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x25
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x26
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x27
                    }
                })
                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("fdf06fad-f744-4451-bb64-ecd792215b10") /* Unknown UUID */, 
                    Package (0x01)
                    {
                        Package (0x02)
                        {
                            "FundamentalDeviceResetTriggeredOnD3ToD0", 
                            One
                        }
                    }
                })
            }

            Device (GPP4)
            {
                Name (_ADR, 0x00020002)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x28
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x29
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x2A
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x2B
                    }
                })
                Device (SDCR)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }
            }

            Device (GPP5)
            {
                Name (_ADR, 0x00020003)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x2C
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x2D
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x2E
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x2F
                    }
                })
                Device (WLAN)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                }

                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("fdf06fad-f744-4451-bb64-ecd792215b10") /* Unknown UUID */, 
                    Package (0x01)
                    {
                        Package (0x02)
                        {
                            "FundamentalDeviceResetTriggeredOnD3ToD0", 
                            One
                        }
                    }
                })
            }

            Device (GPP6)
            {
                Name (_ADR, 0x00020004)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x2E
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x2F
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x2C
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x2D
                    }
                })
                Device (RTL8)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Name (DSEN, 0x00)
                    Name (RPB, Zero)
                    Name (RPD, Zero)
                    Name (RPF, Zero)
                    Method (_INI, 0, Serialized)  // _INI: Initialize
                    {
                        M460 ("PLA-ASL-RTK-DashLanDevice-_INI\n", Zero, Zero, Zero, Zero, Zero, Zero)
                        RPD = (^^_ADR >> 0x10)
                        RPF = (^^_ADR & 0xFFFF)
                        M460 ("PLA-ASL-RTK-DashLanDevice-_INI Parent B/D/F: %X/%X/%X\n", RPB, RPD, RPF, Zero, Zero, Zero)
                    }

                    Method (_REG, 2, NotSerialized)  // _REG: Region Availability
                    {
                        If (((Arg0 == 0x02) && (Arg1 == One)))
                        {
                            M460 ("PLA-ASL-RTK-DashLanDevice-_REG Dash Option: %d\n", DSEN, Zero, Zero, Zero, Zero, Zero)
                            If ((DSEN == Zero))
                            {
                                Local0 = M017 (RPB, RPD, RPF, 0x19, Zero, 0x08)
                                Local1 = M017 (Local0, Zero, Zero, Zero, Zero, 0x10)
                                M460 ("PLA-ASL-RTK-DashLanDevice-_REG Vendor ID: 0x%X\n", Local1, Zero, Zero, Zero, Zero, Zero)
                                If ((Local1 == 0x10EC))
                                {
                                    Local2 = M019 (Local0, Zero, Zero, 0x10)
                                    Local2 &= 0xFFF0
                                    OperationRegion (VAIO, SystemIO, Local2, 0x0100)
                                    Field (VAIO, ByteAcc, NoLock, Preserve)
                                    {
                                        Offset (0x40), 
                                        XX40,   32, 
                                        Offset (0x64), 
                                        XX64,   32, 
                                        XX68,   32, 
                                        Offset (0xB0), 
                                        XXB0,   32
                                    }

                                    Local1 = XX40 /* \_SB_.PCI0.GPP6.RTL8._REG.XX40 */
                                    XXB0 = 0x6E000000
                                    Sleep (0x02)
                                    Local2 = XXB0 /* \_SB_.PCI0.GPP6.RTL8._REG.XXB0 */
                                    If (((Local1 & 0x7C800000) == 0x50000000))
                                    {
                                        M460 ("PLA-ASL-RTK-DashLanDevice-_REG Disable multi-function for RTK8111EP\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                        XX64 = 0xFFFFFFFF
                                        XX68 = 0x8001F000
                                        Sleep (0x02)
                                        XX64 = 0xFFFFFFFF
                                        XX68 = 0x8002F000
                                        Sleep (0x02)
                                        XX64 = 0xFFFFFFFF
                                        XX68 = 0x8003F000
                                        Sleep (0x02)
                                        XX64 = 0xFFFFFFFF
                                        XX68 = 0x8004F000
                                    }
                                    ElseIf (((((Local1 & 0x7CF00000) == 0x54A00000) || ((
                                        Local1 & 0x7CF00000) == 0x54B00000)) && ((Local2 & 0x78) == Zero)))
                                    {
                                        M460 ("PLA-ASL-RTK-DashLanDevice-_REG Disable multi-function for RTK8111FP\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                        XX64 = 0xFFFFFFFF
                                        XX68 = 0x8002F000
                                        Sleep (0x02)
                                        XX68 = 0x8004F000
                                        Sleep (0x02)
                                        XX68 = 0x8007F000
                                    }
                                    Else
                                    {
                                        M460 ("PLA-ASL-RTK-DashLanDevice-_REG Do nothing for other RTK Controller\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                    }
                                }
                            }
                        }
                    }
                }

                Device (RUSB)
                {
                    Name (_ADR, 0x04)  // _ADR: Address
                }

                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("fdf06fad-f744-4451-bb64-ecd792215b10") /* Unknown UUID */, 
                    Package (0x01)
                    {
                        Package (0x02)
                        {
                            "FundamentalDeviceResetTriggeredOnD3ToD0", 
                            One
                        }
                    }
                })
            }

            Device (GPP7)
            {
                Name (_ADR, 0x00020005)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x2A
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x2B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x28
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x29
                    }
                })
                Device (WWAN)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }

                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("fdf06fad-f744-4451-bb64-ecd792215b10") /* Unknown UUID */, 
                    Package (0x01)
                    {
                        Package (0x02)
                        {
                            "FundamentalDeviceResetTriggeredOnD3ToD0", 
                            One
                        }
                    }
                })
            }

            Device (GPP8)
            {
                Name (_ADR, 0x00020006)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x26
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x27
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x24
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x25
                    }
                })
                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("fdf06fad-f744-4451-bb64-ecd792215b10") /* Unknown UUID */, 
                    Package (0x01)
                    {
                        Package (0x02)
                        {
                            "FundamentalDeviceResetTriggeredOnD3ToD0", 
                            One
                        }
                    }
                })
            }

            Device (GPP9)
            {
                Name (_ADR, 0x00030001)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x22
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x23
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x20
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x21
                    }
                })
            }

            Device (GP10)
            {
                Name (_ADR, 0x00030002)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x1E
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x1F
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x1C
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x1D
                    }
                })
                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("fdf06fad-f744-4451-bb64-ecd792215b10") /* Unknown UUID */, 
                    Package (0x01)
                    {
                        Package (0x02)
                        {
                            "FundamentalDeviceResetTriggeredOnD3ToD0", 
                            One
                        }
                    }
                })
            }

            Device (GP11)
            {
                Name (_ADR, 0x00030003)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x1A
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x1B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x18
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x19
                    }
                })
                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("fdf06fad-f744-4451-bb64-ecd792215b10") /* Unknown UUID */, 
                    Package (0x01)
                    {
                        Package (0x02)
                        {
                            "FundamentalDeviceResetTriggeredOnD3ToD0", 
                            One
                        }
                    }
                })
            }

            Device (GP12)
            {
                Name (_ADR, 0x00030004)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x19
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x1A
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x1B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x18
                    }
                })
                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("fdf06fad-f744-4451-bb64-ecd792215b10") /* Unknown UUID */, 
                    Package (0x01)
                    {
                        Package (0x02)
                        {
                            "FundamentalDeviceResetTriggeredOnD3ToD0", 
                            One
                        }
                    }
                })
            }

            Device (GP13)
            {
                Name (_ADR, 0x00030005)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x1D
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x1E
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x1F
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x1C
                    }
                })
                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("fdf06fad-f744-4451-bb64-ecd792215b10") /* Unknown UUID */, 
                    Package (0x01)
                    {
                        Package (0x02)
                        {
                            "FundamentalDeviceResetTriggeredOnD3ToD0", 
                            One
                        }
                    }
                })
            }

            Device (GP14)
            {
                Name (_ADR, 0x00030006)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x21
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x22
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x23
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x20
                    }
                })
                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("fdf06fad-f744-4451-bb64-ecd792215b10") /* Unknown UUID */, 
                    Package (0x01)
                    {
                        Package (0x02)
                        {
                            "FundamentalDeviceResetTriggeredOnD3ToD0", 
                            One
                        }
                    }
                })
            }

            Device (GPPA)
            {
                Name (_ADR, 0x00080001)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x27
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x24
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x25
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x26
                    }
                })
                Device (VGA)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Name (DOSA, Zero)
                    Method (SINI, 0, Serialized)
                    {
                        M460 ("PLA-ASL-\\_SB.PCI0.GPPA.VGA0._INI\n", Zero, Zero, Zero, Zero, Zero, Zero)
                    }

                    Method (SREG, 2, NotSerialized)
                    {
                        M460 ("PLA-ASL-\\_SB.PCI0.GPPA.VGA0._REG Arg0:0x%x Arg1:0x%x\n", Arg0, Arg1, Zero, Zero, Zero, Zero)
                        If ((Arg1 == One))
                        {
                            ALIB (0xBB, Zero)
                            M460 ("PLA-ASL-\\_SB.PCI0.GPPA.VGA0._REG Set/clear the IGPU C2P register DEADBEEF\n", Zero, Zero, Zero, Zero, Zero, Zero)
                        }
                    }

                    Method (_DOS, 1, NotSerialized)  // _DOS: Disable Output Switching
                    {
                        DOSA = Arg0
                    }

                    Method (_DOD, 0, NotSerialized)  // _DOD: Display Output Devices
                    {
                        M460 ("PLA-ASL-\\_SB.PCI0.GPPA.VGA._DOD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                        Return (Package (0x07)
                        {
                            0x00010110, 
                            0x00010210, 
                            0x00010220, 
                            0x00010230, 
                            0x00010240, 
                            0x00031000, 
                            0x00032000
                        })
                    }

                    Device (LCD)
                    {
                        Name (_ADR, 0x0110)  // _ADR: Address
                        Name (BCLB, Package (0x34)
                        {
                            0x5A, 
                            0x3C, 
                            0x02, 
                            0x04, 
                            0x06, 
                            0x08, 
                            0x0A, 
                            0x0C, 
                            0x0E, 
                            0x10, 
                            0x12, 
                            0x14, 
                            0x16, 
                            0x18, 
                            0x1A, 
                            0x1C, 
                            0x1E, 
                            0x20, 
                            0x22, 
                            0x24, 
                            0x26, 
                            0x28, 
                            0x2A, 
                            0x2C, 
                            0x2E, 
                            0x30, 
                            0x32, 
                            0x34, 
                            0x36, 
                            0x38, 
                            0x3A, 
                            0x3C, 
                            0x3E, 
                            0x40, 
                            0x42, 
                            0x44, 
                            0x46, 
                            0x48, 
                            0x4A, 
                            0x4C, 
                            0x4E, 
                            0x50, 
                            0x52, 
                            0x54, 
                            0x56, 
                            0x58, 
                            0x5A, 
                            0x5C, 
                            0x5E, 
                            0x60, 
                            0x62, 
                            0x64
                        })
                        Method (_BCL, 0, NotSerialized)  // _BCL: Brightness Control Levels
                        {
                            M460 ("PLA-ASL-\\_SB.PCI0.GPPA.VGA.LCD._BCL\n", Zero, Zero, Zero, Zero, Zero, Zero)
                            Return (BCLB) /* \_SB_.PCI0.GPPA.VGA_.LCD_.BCLB */
                        }

                        Method (_BCM, 1, NotSerialized)  // _BCM: Brightness Control Method
                        {
                            M460 ("PLA-ASL-\\_SB.PCI0.GPPA.VGA.LCD._BCM Arg0 = 0x%X\n", ToInteger (Arg0), Zero, Zero, Zero, Zero, Zero)
                            Divide ((Arg0 * 0xFF), 0x64, Local1, Local0)
                            AFN7 (Local0)
                        }
                    }
                }

                Device (PSP)
                {
                    Name (_ADR, 0x02)  // _ADR: Address
                }

                Device (ACP)
                {
                    Name (_ADR, 0x05)  // _ADR: Address
                }

                Device (AZAL)
                {
                    Name (_ADR, 0x06)  // _ADR: Address
                }

                Device (HDAU)
                {
                    Name (_ADR, One)  // _ADR: Address
                }

                Device (XHC1)
                {
                    Name (_ADR, 0x04)  // _ADR: Address
                    Device (RHUB)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Name (CONN, Zero)
                        Name (TYPP, 0xFF)
                        Name (VISS, Zero)
                        Device (PRT1)
                        {
                            Name (_ADR, One)  // _ADR: Address
                            Device (CAM0)
                            {
                                Name (_ADR, One)  // _ADR: Address
                                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                                {
                                    M460 ("PLA-ASL-\\_SB.PCI0.GPPA.XHC1.RHUB.PRT1.CAM0._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                    Return (M601 (0x04, Zero, 0x08, Zero, 0x0104, 0x00AF00E1))
                                }
                            }

                            Device (CAM1)
                            {
                                Name (_ADR, 0x03)  // _ADR: Address
                                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                                {
                                    M460 ("PLA-ASL-\\_SB.PCI0.GPPA.XHC1.RHUB.PRT1.CAM1._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                    Return (M601 (0x04, Zero, 0x08, Zero, 0x0104, 0x00AF00E1))
                                }
                            }

                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPA.XHC1.RHUB.PRT1._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M602 (CONN, TYPP, Zero))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPA.XHC1.RHUB.PRT1._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x02, VISS, 0x0101, 0x03, 0x0112, Zero))
                            }
                        }

                        Device (PRT2)
                        {
                            Name (_ADR, 0x02)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPA.XHC1.RHUB.PRT2._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M602 (One, Zero, Zero))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPA.XHC1.RHUB.PRT2._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x02, Zero, 0x0101, 0x03, 0x0112, Zero))
                            }
                        }
                    }
                }

                Device (MP2C)
                {
                    Name (_ADR, 0x07)  // _ADR: Address
                }
            }

            Device (GPPB)
            {
                Name (_ADR, 0x00080002)  // _ADR: Address
                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x2B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x28
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x29
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x2A
                    }
                })
                Device (IPU)
                {
                    Name (_ADR, One)  // _ADR: Address
                }
            }

            Device (GPPC)
            {
                Name (_ADR, 0x00080003)  // _ADR: Address
                Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                {
                    If ((Arg0 == ToUUID ("e5c937d0-3553-4d7a-9117-ea4d19c3434d") /* Device Labeling Interface */))
                    {
                        Switch (ToInteger (Arg2))
                        {
                            Case (Zero)
                            {
                                Return (Buffer (One)
                                {
                                     0xFF                                             // .
                                })
                            }
                            Case (0x05)
                            {
                                Return (Zero)
                            }
                            Default
                            {
                                Return (Zero)
                            }

                        }
                    }
                    Else
                    {
                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }
                }

                Name (_PRT, Package (0x04)  // _PRT: PCI Routing Table
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x2F
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x2C
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x2D
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x2E
                    }
                })
                Device (XHC0)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Device (RHUB)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Device (PRT1)
                        {
                            Name (_ADR, One)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT1._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M602 (One, 0x03, Zero))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT1._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x02, One, One, 0x03, 0x0112, Zero))
                            }
                        }

                        Device (PRT2)
                        {
                            Name (_ADR, 0x02)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT2._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M602 (One, 0x03, Zero))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT2._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x02, One, 0x02, 0x03, 0x0112, Zero))
                            }
                        }

                        Device (PRT3)
                        {
                            Name (_ADR, 0x03)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT3._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M602 (One, 0xFF, Zero))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT3._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x02, Zero, 0x03, Zero, 0x0112, Zero))
                            }
                        }

                        Device (PRT4)
                        {
                            Name (_ADR, 0x04)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT4._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M602 (One, Zero, Zero))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT4._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x02, Zero, 0x04, 0x03, 0x0112, Zero))
                            }
                        }

                        Device (PRT5)
                        {
                            Name (_ADR, 0x05)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT5._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M602 (One, Zero, Zero))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT5._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x02, Zero, 0x05, 0x03, 0x0112, Zero))
                            }
                        }

                        Device (PRT6)
                        {
                            Name (_ADR, 0x06)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT6._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M602 (One, 0x03, Zero))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT6._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x02, One, One, 0x03, 0x0112, Zero))
                            }
                        }

                        Device (PRT7)
                        {
                            Name (_ADR, 0x07)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT7._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M602 (One, 0x03, Zero))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC0.RHUB.PRT7._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x02, One, 0x02, 0x03, 0x0112, Zero))
                            }
                        }
                    }
                }

                Device (XHC3)
                {
                    Name (_ADR, 0x03)  // _ADR: Address
                    Device (RHUB)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Device (PRT1)
                        {
                            Name (_ADR, One)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC3.RHUB.PRT1._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Local0 = 0x3D
                                If (CondRefOf (\_SB.U4PC))
                                {
                                    If (((U4PC & 0x04) == Zero))
                                    {
                                        Local0 &= 0xFB
                                    }
                                }

                                Return (M602 (One, 0x09, Local0))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC3.RHUB.PRT1._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x03, One, 0x0301, 0x03, 0x0112, Zero))
                            }
                        }

                        Device (PRT2)
                        {
                            Name (_ADR, 0x02)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC3.RHUB.PRT2._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Local0 = 0x3D
                                If (CondRefOf (\_SB.U4PC))
                                {
                                    If (((U4PC & 0x04) == Zero))
                                    {
                                        Local0 &= 0xFB
                                    }
                                }

                                Return (M602 (One, 0x09, Local0))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC3.RHUB.PRT2._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x03, One, 0x0301, 0x03, 0x0112, Zero))
                            }
                        }
                    }
                }

                Device (XHC4)
                {
                    Name (_ADR, 0x04)  // _ADR: Address
                    Device (RHUB)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Device (PRT1)
                        {
                            Name (_ADR, One)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC4.RHUB.PRT1._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Local0 = 0x3D
                                If (CondRefOf (\_SB.U4PC))
                                {
                                    If (((U4PC & 0x04) == Zero))
                                    {
                                        Local0 &= 0xFB
                                    }
                                }

                                Return (M602 (One, 0x03, Zero))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC4.RHUB.PRT1._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x02, One, 0x0401, 0x03, 0x0112, Zero))
                            }
                        }

                        Device (PRT2)
                        {
                            Name (_ADR, 0x02)  // _ADR: Address
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC4.RHUB.PRT2._UPC\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Local0 = 0x3D
                                If (CondRefOf (\_SB.U4PC))
                                {
                                    If (((U4PC & 0x04) == Zero))
                                    {
                                        Local0 &= 0xFB
                                    }
                                }

                                Return (M602 (One, 0x03, Zero))
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GPPC.XHC4.RHUB.PRT2._PLD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                Return (M601 (0x02, One, 0x0401, 0x03, 0x0112, Zero))
                            }
                        }
                    }
                }

                Device (NHI0)
                {
                    Name (_ADR, 0x05)  // _ADR: Address
                }

                Device (NHI1)
                {
                    Name (_ADR, 0x06)  // _ADR: Address
                }
            }

            Device (HPET)
            {
                Name (_HID, EisaId ("PNP0103") /* HPET System Timer */)  // _HID: Hardware ID
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                {
                    M460 ("PLA-ASL-\\_SB.PCI0.HPET._CRS\n", Zero, Zero, Zero, Zero, Zero, Zero)
                    Name (BUF0, Buffer (0x14)
                    {
                        /* 0000 */  0x22, 0x01, 0x00, 0x22, 0x00, 0x01, 0x86, 0x09,  // ".."....
                        /* 0008 */  0x00, 0x00, 0x00, 0x00, 0xD0, 0xFE, 0x00, 0x04,  // ........
                        /* 0010 */  0x00, 0x00, 0x79, 0x00                           // ..y.
                    })
                    CreateDWordField (BUF0, 0x0A, HPEB)
                    Local0 = 0xFED00000
                    HPEB = (Local0 & 0xFFFFFC00)
                    Return (BUF0) /* \_SB_.PCI0.HPET._CRS.BUF0 */
                }
            }

            Device (SMBS)
            {
                Name (_ADR, 0x00140000)  // _ADR: Address
            }

            Scope (SBRG)
            {
                Device (DMAC)
                {
                    Name (_HID, EisaId ("PNP0200") /* PC-class DMA Controller */)  // _HID: Hardware ID
                    Name (_CRS, Buffer (0x1D)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x10,  // G.......
                        /* 0008 */  0x47, 0x01, 0x81, 0x00, 0x81, 0x00, 0x01, 0x0F,  // G.......
                        /* 0010 */  0x47, 0x01, 0xC0, 0x00, 0xC0, 0x00, 0x01, 0x20,  // G...... 
                        /* 0018 */  0x2A, 0x10, 0x01, 0x79, 0x00                     // *..y.
                    })
                }

                Device (COPR)
                {
                    Name (_HID, EisaId ("PNP0C04") /* x87-compatible Floating Point Processing Unit */)  // _HID: Hardware ID
                    Name (_CRS, Buffer (0x0D)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0xF0, 0x00, 0xF0, 0x00, 0x01, 0x0F,  // G.......
                        /* 0008 */  0x22, 0x00, 0x20, 0x79, 0x00                     // ". y.
                    })
                }

                Device (PIC)
                {
                    Name (_HID, EisaId ("PNP0000") /* 8259-compatible Programmable Interrupt Controller */)  // _HID: Hardware ID
                    Name (_CRS, Buffer (0x15)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x20, 0x00, 0x20, 0x00, 0x01, 0x02,  // G. . ...
                        /* 0008 */  0x47, 0x01, 0xA0, 0x00, 0xA0, 0x00, 0x01, 0x02,  // G.......
                        /* 0010 */  0x22, 0x04, 0x00, 0x79, 0x00                     // "..y.
                    })
                }

                Device (RTC)
                {
                    Name (_HID, EisaId ("PNP0B00") /* AT Real-Time Clock */)  // _HID: Hardware ID
                    Name (_FIX, Package (0x01)  // _FIX: Fixed Register Resource Provider
                    {
                        0x000BD041
                    })
                    Name (_CRS, Buffer (0x12)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x70, 0x00, 0x70, 0x00, 0x01, 0x02,  // G.p.p...
                        /* 0008 */  0x47, 0x01, 0x72, 0x00, 0x72, 0x00, 0x01, 0x02,  // G.r.r...
                        /* 0010 */  0x79, 0x00                                       // y.
                    })
                }

                Device (SPKR)
                {
                    Name (_HID, EisaId ("PNP0800") /* Microsoft Sound System Compatible Device */)  // _HID: Hardware ID
                    Name (_CRS, Buffer (0x0A)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x61, 0x00, 0x61, 0x00, 0x01, 0x01,  // G.a.a...
                        /* 0008 */  0x79, 0x00                                       // y.
                    })
                }

                Device (TMR)
                {
                    Name (_HID, EisaId ("PNP0100") /* PC-class System Timer */)  // _HID: Hardware ID
                    Name (_CRS, Buffer (0x0A)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x40, 0x00, 0x40, 0x00, 0x01, 0x04,  // G.@.@...
                        /* 0008 */  0x79, 0x00                                       // y.
                    })
                }
            }
        }
    }

    Name (TSOS, 0x75)
    Name (HCIB, One)
    Name (I2A0, 0x05)
    Name (I2A1, 0x06)
    Name (I2A2, 0x07)
    Name (I2A3, 0x08)
    Name (UAA0, 0x0B)
    Name (UAA1, 0x0C)
    Name (I3A1, 0x0D)
    Name (I3A2, 0x0E)
    Name (I3A3, 0x0F)
    Name (UAA2, 0x10)
    Name (UAA4, 0x14)
    Name (I3A0, 0x15)
    Name (UAA3, 0x1A)
    If (CondRefOf (\_OSI))
    {
        If (_OSI ("Windows 2009"))
        {
            TSOS = 0x50
        }

        If (_OSI ("Windows 2015"))
        {
            TSOS = 0x70
        }
    }

    Scope (_SB)
    {
        OperationRegion (SMIC, SystemMemory, 0xFED80000, 0x00800000)
        Field (SMIC, ByteAcc, NoLock, Preserve)
        {
            Offset (0x36A), 
            SMIB,   8
        }

        OperationRegion (SSMI, SystemIO, SMIB, 0x02)
        Field (SSMI, AnyAcc, NoLock, Preserve)
        {
            SMIW,   16
        }

        OperationRegion (ECMC, SystemIO, 0x72, 0x02)
        Field (ECMC, AnyAcc, NoLock, Preserve)
        {
            ECMI,   8, 
            ECMD,   8
        }

        IndexField (ECMI, ECMD, ByteAcc, NoLock, Preserve)
        {
            Offset (0x08), 
            FRTB,   32
        }

        OperationRegion (FRTP, SystemMemory, FRTB, 0x0100)
        Field (FRTP, AnyAcc, NoLock, Preserve)
        {
            PEBA,   32, 
            Offset (0x04), 
                ,   5, 
            IC0E,   1, 
            IC1E,   1, 
            IC2E,   1, 
            IC3E,   1, 
            IC4E,   1, 
            IC5E,   1, 
            UT0E,   1, 
            UT1E,   1, 
            I31E,   1, 
            I32E,   1, 
            I33E,   1, 
            UT2E,   1, 
                ,   1, 
            EMMD,   2, 
            UT4E,   1, 
            I30E,   1, 
                ,   1, 
            XHCE,   1, 
                ,   1, 
                ,   1, 
            UT3E,   1, 
            ESPI,   1, 
            EMME,   1, 
            HFPE,   1, 
            HD0E,   1, 
            HD2E,   1, 
            Offset (0x08), 
            PCEF,   1, 
                ,   4, 
            IC0D,   1, 
            IC1D,   1, 
            IC2D,   1, 
            IC3D,   1, 
            IC4D,   1, 
            IC5D,   1, 
            UT0D,   1, 
            UT1D,   1, 
            I31D,   1, 
            I32D,   1, 
            I33D,   1, 
            UT2D,   1, 
                ,   1, 
            EHCD,   1, 
                ,   1, 
            UT4D,   1, 
            I30D,   1, 
                ,   1, 
            XHCD,   1, 
            SD_D,   1, 
                ,   1, 
            UT3D,   1, 
                ,   1, 
            EMD3,   1, 
                ,   1, 
            US4D,   1, 
            S03D,   1, 
            UT0O,   1, 
            UT1O,   1, 
            UT2O,   1, 
            UT3O,   1, 
            Offset (0x1A), 
            I30M,   1, 
            I31M,   1, 
            I32M,   1, 
            I33M,   1, 
            Offset (0x2D), 
            UT0I,   1, 
            UT1I,   1, 
            UT2I,   1, 
            UT3I,   1, 
            UT4I,   1, 
            Offset (0x2E), 
            UL0I,   1, 
            UL1I,   1, 
            UL2I,   1, 
            UL3I,   1
        }

        OperationRegion (FCFG, SystemMemory, PEBA, 0x01000000)
        Field (FCFG, DWordAcc, NoLock, Preserve)
        {
            Offset (0xA3078), 
                ,   2, 
            LDQ0,   1, 
            Offset (0xA30CB), 
                ,   7, 
            AUSS,   1
        }

        OperationRegion (IOMX, SystemMemory, 0xFED80D00, 0x0100)
        Field (IOMX, AnyAcc, NoLock, Preserve)
        {
            Offset (0x15), 
            IM15,   8, 
            Offset (0x16), 
            IM16,   8, 
            Offset (0x1F), 
            IM1F,   8, 
            Offset (0x20), 
            IM20,   8, 
            Offset (0x44), 
            IM44,   8, 
            Offset (0x46), 
            IM46,   8, 
            Offset (0x4A), 
            IM4A,   8, 
            Offset (0x4B), 
            IM4B,   8, 
            Offset (0x57), 
            IM57,   8, 
            Offset (0x58), 
            IM58,   8, 
            Offset (0x68), 
            IM68,   8, 
            Offset (0x69), 
            IM69,   8, 
            Offset (0x6A), 
            IM6A,   8, 
            Offset (0x6B), 
            IM6B,   8, 
            Offset (0x6D), 
            IM6D,   8
        }

        OperationRegion (FACR, SystemMemory, 0xFED81E00, 0x0100)
        Field (FACR, AnyAcc, NoLock, Preserve)
        {
            Offset (0x80), 
                ,   28, 
            RD28,   1, 
                ,   1, 
            RQTY,   1, 
            Offset (0x84), 
                ,   28, 
            SD28,   1, 
                ,   1, 
            Offset (0xA0), 
            PG1A,   1
        }

        OperationRegion (LUIE, SystemMemory, 0xFEDC0020, 0x04)
        Field (LUIE, AnyAcc, NoLock, Preserve)
        {
            IER0,   1, 
            IER1,   1, 
            IER2,   1, 
            IER3,   1, 
            UOL0,   1, 
            UOL1,   1, 
            UOL2,   1, 
            UOL3,   1, 
            WUR0,   2, 
            WUR1,   2, 
            WUR2,   2, 
            WUR3,   2
        }

        Method (FRUI, 1, Serialized)
        {
            If ((Arg0 == Zero))
            {
                Return (IUA0) /* \_SB_.IUA0 */
            }
            ElseIf ((Arg0 == One))
            {
                Return (IUA1) /* \_SB_.IUA1 */
            }
            ElseIf ((Arg0 == 0x02))
            {
                Return (IUA2) /* \_SB_.IUA2 */
            }
            ElseIf ((Arg0 == 0x03))
            {
                Return (IUA3) /* \_SB_.IUA3 */
            }
            Else
            {
                Return (0x03)
            }
        }

        Method (FUIO, 1, Serialized)
        {
            If ((IER0 == One))
            {
                If ((WUR0 == Arg0))
                {
                    Return (Zero)
                }
            }

            If ((IER1 == One))
            {
                If ((WUR1 == Arg0))
                {
                    Return (One)
                }
            }

            If ((IER2 == One))
            {
                If ((WUR2 == Arg0))
                {
                    Return (0x02)
                }
            }

            If ((IER3 == One))
            {
                If ((WUR3 == Arg0))
                {
                    Return (0x03)
                }
            }

            Return (0x0F)
        }

        Method (SRAD, 2, Serialized)
        {
            Local0 = (Arg0 << One)
            Local0 += 0xFED81E40
            OperationRegion (ADCR, SystemMemory, Local0, 0x02)
            Field (ADCR, ByteAcc, NoLock, Preserve)
            {
                ADTD,   2, 
                ADPS,   1, 
                ADPD,   1, 
                ADSO,   1, 
                ADSC,   1, 
                ADSR,   1, 
                ADIS,   1, 
                ADDS,   3
            }

            ADIS = One
            ADSR = Zero
            Stall (Arg1)
            ADSR = One
            ADIS = Zero
            Stall (Arg1)
        }

        Method (DSAD, 2, Serialized)
        {
            Local0 = (Arg0 << One)
            Local0 += 0xFED81E40
            OperationRegion (ADCR, SystemMemory, Local0, 0x02)
            Field (ADCR, ByteAcc, NoLock, Preserve)
            {
                ADTD,   2, 
                ADPS,   1, 
                ADPD,   1, 
                ADSO,   1, 
                ADSC,   1, 
                ADSR,   1, 
                ADIS,   1, 
                ADDS,   3
            }

            If ((Arg1 != ADTD))
            {
                If ((Arg1 == Zero))
                {
                    ADTD = Zero
                    ADPD = One
                    Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    While ((Local0 != 0x07))
                    {
                        Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    }
                }

                If ((Arg1 == 0x03))
                {
                    ADPD = Zero
                    Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    While ((Local0 != Zero))
                    {
                        Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    }

                    ADTD = 0x03
                }
            }
        }

        Method (HSAD, 2, Serialized)
        {
            Local3 = (One << Arg0)
            Local0 = (Arg0 << One)
            Local0 += 0xFED81E40
            OperationRegion (ADCR, SystemMemory, Local0, 0x02)
            Field (ADCR, ByteAcc, NoLock, Preserve)
            {
                ADTD,   2, 
                ADPS,   1, 
                ADPD,   1, 
                ADSO,   1, 
                ADSC,   1, 
                ADSR,   1, 
                ADIS,   1, 
                ADDS,   3
            }

            If ((Arg1 != ADTD))
            {
                If ((Arg1 == Zero))
                {
                    PG1A = One
                    ADTD = Zero
                    ADPD = One
                    Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    While ((Local0 != 0x07))
                    {
                        Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    }

                    RQTY = One
                    RD28 = One
                    Local0 = SD28 /* \_SB_.SD28 */
                    While (!Local0)
                    {
                        Local0 = SD28 /* \_SB_.SD28 */
                    }
                }

                If ((Arg1 == 0x03))
                {
                    RQTY = Zero
                    RD28 = One
                    Local0 = SD28 /* \_SB_.SD28 */
                    While (Local0)
                    {
                        Local0 = SD28 /* \_SB_.SD28 */
                    }

                    ADPD = Zero
                    Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    While ((Local0 != Zero))
                    {
                        Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    }

                    ADTD = 0x03
                    PG1A = Zero
                }
            }
        }

        OperationRegion (FPIC, SystemIO, 0x0C00, 0x02)
        Field (FPIC, AnyAcc, NoLock, Preserve)
        {
            FPII,   8, 
            FPID,   8
        }

        IndexField (FPII, FPID, ByteAcc, NoLock, Preserve)
        {
            Offset (0xF0), 
            IC0I,   8, 
            Offset (0xF1), 
            IC1I,   8, 
            Offset (0xF2), 
            IC2I,   8, 
            Offset (0xF3), 
            IC3I,   8, 
            Offset (0xF4), 
            IUA0,   8, 
            Offset (0xF5), 
            IUA1,   8, 
            Offset (0xF7), 
            IUA4,   8, 
            Offset (0xF8), 
            IUA2,   8, 
            Offset (0xF9), 
            IUA3,   8
        }
    }

    Scope (_SB)
    {
        Device (HFP1)
        {
            Name (_HID, "AMDI0060")  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (HFPE)
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x0E)
                {
                    /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x10, 0xC1, 0xFE,  // ........
                    /* 0008 */  0x00, 0x01, 0x00, 0x00, 0x79, 0x00               // ....y.
                })
                Return (RBUF) /* \_SB_.HFP1._CRS.RBUF */
            }
        }

        Device (HID0)
        {
            Name (_HID, "AMDI0063")  // _HID: Hardware ID
            Name (_CID, "PNP0C51")  // _CID: Compatible ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (HD0E)
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x31)
                {
                    /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x30, 0xC1, 0xFE,  // .....0..
                    /* 0008 */  0x00, 0x02, 0x00, 0x00, 0x8C, 0x20, 0x00, 0x01,  // ..... ..
                    /* 0010 */  0x00, 0x01, 0x00, 0x19, 0x00, 0x03, 0x00, 0x00,  // ........
                    /* 0018 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
                    /* 0020 */  0x00, 0x00, 0x00, 0xAB, 0x00, 0x5C, 0x5F, 0x53,  // .....\_S
                    /* 0028 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x79,  // B.GPIO.y
                    /* 0030 */  0x00                                             // .
                })
                Return (RBUF) /* \_SB_.HID0._CRS.RBUF */
            }
        }

        Device (HID2)
        {
            Name (_HID, "AMDI0063")  // _HID: Hardware ID
            Name (_CID, "PNP0C51")  // _CID: Compatible ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (HD2E)
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x31)
                {
                    /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x20, 0xC1, 0xFE,  // ..... ..
                    /* 0008 */  0x00, 0x02, 0x00, 0x00, 0x8C, 0x20, 0x00, 0x01,  // ..... ..
                    /* 0010 */  0x00, 0x01, 0x00, 0x19, 0x00, 0x03, 0x00, 0x00,  // ........
                    /* 0018 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
                    /* 0020 */  0x00, 0x00, 0x00, 0xAB, 0x00, 0x5C, 0x5F, 0x53,  // .....\_S
                    /* 0028 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x79,  // B.GPIO.y
                    /* 0030 */  0x00                                             // .
                })
                Return (RBUF) /* \_SB_.HID2._CRS.RBUF */
            }
        }

        Device (GPIO)
        {
            Name (_HID, "AMDI0030")  // _HID: Hardware ID
            Name (_CID, "AMDI0030")  // _CID: Compatible ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x17)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x0D, 0x01, 0x07, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x15, 0xD8,  // ........
                    /* 0010 */  0xFE, 0x00, 0x04, 0x00, 0x00, 0x79, 0x00         // .....y.
                })
                Return (RBUF) /* \_SB_.GPIO._CRS.RBUF */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

        Device (PPKG)
        {
            Name (_HID, "AMDI0052")  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }
    }

    Scope (_SB)
    {
        Device (FUR0)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If (CondRefOf (UT0O, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return ("AMDI0029")
                    }
                }

                Return ("AMDI0020")
            }

            Name (_UID, "ID00")  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x23)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x03, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x90, 0xDC,  // ........
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00,  // ........
                    /* 0018 */  0x01, 0x00, 0x70, 0xDC, 0xFE, 0x00, 0x10, 0x00,  // ..p.....
                    /* 0020 */  0x00, 0x79, 0x00                                 // .y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IUA0 /* \_SB_.IUA0 */
                Return (BUF0) /* \_SB_.FUR0._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((UT0I == One))
                {
                    Return (Zero)
                }

                If ((TSOS >= 0x70))
                {
                    If ((UT0E == One))
                    {
                        If ((FUIO (Zero) == 0x0F))
                        {
                            Return (0x0F)
                        }
                    }
                }

                Return (Zero)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((UT0D && UT0E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((UT0D && UT0E))
                {
                    DSAD (0x0B, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((UT0D && UT0E))
                {
                    DSAD (0x0B, 0x03)
                }
            }
        }

        Device (FUR1)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If (CondRefOf (UT1O, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return ("AMDI0029")
                    }
                }

                Return ("AMDI0020")
            }

            Name (_UID, "ID01")  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x23)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x11, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0xA0, 0xDC,  // ........
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00,  // ........
                    /* 0018 */  0x01, 0x00, 0x80, 0xDC, 0xFE, 0x00, 0x10, 0x00,  // ........
                    /* 0020 */  0x00, 0x79, 0x00                                 // .y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IUA1 /* \_SB_.IUA1 */
                Return (BUF0) /* \_SB_.FUR1._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((UT1I == One))
                {
                    Return (Zero)
                }

                If ((TSOS >= 0x70))
                {
                    If ((UT1E == One))
                    {
                        If ((FUIO (One) == 0x0F))
                        {
                            Return (0x0F)
                        }
                    }
                }

                Return (Zero)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((UT1D && UT1E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((UT1D && UT1E))
                {
                    DSAD (0x0C, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((UT1D && UT1E))
                {
                    DSAD (0x0C, 0x03)
                }
            }
        }

        Device (FUR2)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If (CondRefOf (UT2O, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return ("AMDI0029")
                    }
                }

                Return ("AMDI0020")
            }

            Name (_UID, "ID02")  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x23)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x05, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0xE0, 0xDC,  // ........
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00,  // ........
                    /* 0018 */  0x01, 0x00, 0xC0, 0xDC, 0xFE, 0x00, 0x10, 0x00,  // ........
                    /* 0020 */  0x00, 0x79, 0x00                                 // .y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IUA2 /* \_SB_.IUA2 */
                Return (BUF0) /* \_SB_.FUR2._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((UT2I == One))
                {
                    Return (Zero)
                }

                If ((TSOS >= 0x70))
                {
                    If ((UT2E == One))
                    {
                        If ((FUIO (0x02) == 0x0F))
                        {
                            Return (0x0F)
                        }
                    }
                }

                Return (Zero)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((UT2D && UT2E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((UT2D && UT2E))
                {
                    DSAD (0x10, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((UT2D && UT2E))
                {
                    DSAD (0x10, 0x03)
                }
            }
        }

        Device (FUR3)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If (CondRefOf (UT3O, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return ("AMDI0029")
                    }
                }

                Return ("AMDI0020")
            }

            Name (_UID, "ID03")  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x23)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x12, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0xF0, 0xDC,  // ........
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00,  // ........
                    /* 0018 */  0x01, 0x00, 0xD0, 0xDC, 0xFE, 0x00, 0x10, 0x00,  // ........
                    /* 0020 */  0x00, 0x79, 0x00                                 // .y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IUA3 /* \_SB_.IUA3 */
                Return (BUF0) /* \_SB_.FUR3._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((UT3I == One))
                {
                    Return (Zero)
                }

                If ((TSOS >= 0x70))
                {
                    If ((UT3E == One))
                    {
                        If ((FUIO (0x03) == 0x0F))
                        {
                            Return (0x0F)
                        }
                    }
                }

                Return (Zero)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((UT3D && UT3E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((UT3D && UT3E))
                {
                    DSAD (0x1A, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((UT3D && UT3E))
                {
                    DSAD (0x1A, 0x03)
                }
            }
        }

        Device (FUR4)
        {
            Name (_HID, "AMDI0020")  // _HID: Hardware ID
            Name (_UID, "ID04")  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x23)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x10, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x10, 0xDD,  // ........
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00,  // ........
                    /* 0018 */  0x01, 0x00, 0x00, 0xDD, 0xFE, 0x00, 0x10, 0x00,  // ........
                    /* 0020 */  0x00, 0x79, 0x00                                 // .y.
                })
                CreateByteField (BUF0, 0x05, IRQB)
                IRQB = IUA4 /* \_SB_.IUA4 */
                Return (BUF0) /* \_SB_.FUR4._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((UT4I == One))
                {
                    Return (Zero)
                }

                If ((TSOS >= 0x70))
                {
                    If ((UT4E == One))
                    {
                        If ((FUIO (0x04) == 0x0F))
                        {
                            Return (0x0F)
                        }
                    }
                }

                Return (Zero)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((UT4D && UT4E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((UT4D && UT4E))
                {
                    DSAD (0x14, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((UT4D && UT4E))
                {
                    DSAD (0x14, 0x03)
                }
            }
        }
    }

    Scope (_SB)
    {
        Device (I2CA)
        {
            Name (_HID, "AMDI0010")  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x17)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x0A, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x20, 0xDC,  // ...... .
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x79, 0x00         // .....y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IC0I /* \_SB_.IC0I */
                Return (BUF0) /* \_SB_.I2CA._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (CondRefOf (I20I, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return (Zero)
                    }
                }

                If ((TSOS >= 0x70))
                {
                    If ((IC0E == One))
                    {
                        Return (0x0F)
                    }
                }

                Return (Zero)
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (I2A0, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((IC0D && IC0E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((IC0D && IC0E))
                {
                    DSAD (I2A0, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((IC0D && IC0E))
                {
                    DSAD (I2A0, 0x03)
                }
            }
        }

        Device (I2CB)
        {
            Name (_HID, "AMDI0010")  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x17)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x0B, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x30, 0xDC,  // ......0.
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x79, 0x00         // .....y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IC1I /* \_SB_.IC1I */
                Return (BUF0) /* \_SB_.I2CB._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (CondRefOf (I21I, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return (Zero)
                    }
                }

                If ((TSOS >= 0x70))
                {
                    If ((IC1E == One))
                    {
                        Return (0x0F)
                    }
                }

                Return (Zero)
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (I2A1, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((IC1D && IC1E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((IC1D && IC1E))
                {
                    DSAD (I2A1, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((IC1D && IC1E))
                {
                    DSAD (I2A1, 0x03)
                }
            }
        }

        Device (I2CC)
        {
            Name (_HID, "AMDI0010")  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x17)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x04, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x40, 0xDC,  // ......@.
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x79, 0x00         // .....y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IC2I /* \_SB_.IC2I */
                Return (BUF0) /* \_SB_.I2CC._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (CondRefOf (I22I, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return (Zero)
                    }
                }

                If ((TSOS >= 0x70))
                {
                    If ((IC2E == One))
                    {
                        Return (0x0F)
                    }
                }

                Return (Zero)
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (I2A2, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((IC2D && IC2E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((IC2D && IC2E))
                {
                    DSAD (I2A2, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((IC2D && IC2E))
                {
                    DSAD (I2A2, 0x03)
                }
            }
        }

        Device (I2CD)
        {
            Name (_HID, "AMDI0010")  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x17)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x06, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x50, 0xDC,  // ......P.
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x79, 0x00         // .....y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IC3I /* \_SB_.IC3I */
                Return (BUF0) /* \_SB_.I2CD._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (CondRefOf (I23I, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return (Zero)
                    }
                }

                If ((TSOS >= 0x70))
                {
                    If ((IC3E == One))
                    {
                        Return (0x0F)
                    }
                }

                Return (Zero)
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (I2A3, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((IC3D && IC3E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((IC3D && IC3E))
                {
                    DSAD (I2A3, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((IC3D && IC3E))
                {
                    DSAD (I2A3, 0x03)
                }
            }
        }
    }

    Scope (_SB.I2CA)
    {
        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            If ((Arg0 == ToUUID ("d93e4d1c-58bb-493c-a06a-605a717f9e2e") /* Unknown UUID */))
            {
                Switch (ToInteger (Arg2))
                {
                    Case (Zero)
                    {
                        Return (Buffer (One)
                        {
                             0x03                                             // .
                        })
                    }
                    Case (One)
                    {
                        Return (Buffer (0x04)
                        {
                             0xE5, 0x00, 0x6A, 0x00                           // ..j.
                        })
                    }

                }
            }
            Else
            {
                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }
        }
    }

    Scope (_SB.I2CB)
    {
        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            If ((Arg0 == ToUUID ("d93e4d1c-58bb-493c-a06a-605a717f9e2e") /* Unknown UUID */))
            {
                Switch (ToInteger (Arg2))
                {
                    Case (Zero)
                    {
                        Return (Buffer (One)
                        {
                             0x03                                             // .
                        })
                    }
                    Case (One)
                    {
                        Return (Buffer (0x04)
                        {
                             0xE5, 0x00, 0x6A, 0x00                           // ..j.
                        })
                    }

                }
            }
            Else
            {
                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }
        }
    }

    Scope (_SB.I2CC)
    {
        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            If ((Arg0 == ToUUID ("d93e4d1c-58bb-493c-a06a-605a717f9e2e") /* Unknown UUID */))
            {
                Switch (ToInteger (Arg2))
                {
                    Case (Zero)
                    {
                        Return (Buffer (One)
                        {
                             0x03                                             // .
                        })
                    }
                    Case (One)
                    {
                        Return (Buffer (0x04)
                        {
                             0xE5, 0x00, 0x6A, 0x00                           // ..j.
                        })
                    }

                }
            }
            Else
            {
                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }
        }
    }

    Scope (_SB.I2CD)
    {
        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            If ((Arg0 == ToUUID ("d93e4d1c-58bb-493c-a06a-605a717f9e2e") /* Unknown UUID */))
            {
                Switch (ToInteger (Arg2))
                {
                    Case (Zero)
                    {
                        Return (Buffer (One)
                        {
                             0x03                                             // .
                        })
                    }
                    Case (One)
                    {
                        Return (Buffer (0x04)
                        {
                             0xE5, 0x00, 0x6A, 0x00                           // ..j.
                        })
                    }

                }
            }
            Else
            {
                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }
        }
    }

    Scope (_SB)
    {
        Name (I3ID, "AMDI0015")
        Name (I2ID, "AMDI0016")
        Name (HCID, "AMDI5017")
        Device (I3CA)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((I30M == Zero))
                {
                    If (CondRefOf (HCIB))
                    {
                        Return (HCID) /* \_SB_.HCID */
                    }
                    Else
                    {
                        Return (I3ID) /* \_SB_.I3ID */
                    }
                }
                Else
                {
                    Return (I2ID) /* \_SB_.I2ID */
                }
            }

            Name (_UID, Zero)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x17)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x0A, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x20, 0xDD,  // ...... .
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x79, 0x00         // .....y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IC0I /* \_SB_.IC0I */
                Return (BUF0) /* \_SB_.I3CA._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (CondRefOf (I30I, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return (Zero)
                    }
                }

                If ((TSOS >= 0x70))
                {
                    If ((I30E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (I3A0, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((I30D && I30E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((I30D && I30E))
                {
                    DSAD (I3A0, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((I30D && I30E))
                {
                    DSAD (I3A0, 0x03)
                }
            }
        }

        Device (I3CB)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((I31M == Zero))
                {
                    If (CondRefOf (HCIB))
                    {
                        Return (HCID) /* \_SB_.HCID */
                    }
                    Else
                    {
                        Return (I3ID) /* \_SB_.I3ID */
                    }
                }
                Else
                {
                    Return (I2ID) /* \_SB_.I2ID */
                }
            }

            Name (_UID, One)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x17)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x0B, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x30, 0xDD,  // ......0.
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x79, 0x00         // .....y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IC1I /* \_SB_.IC1I */
                Return (BUF0) /* \_SB_.I3CB._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (CondRefOf (I31I, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return (Zero)
                    }
                }

                If ((TSOS >= 0x70))
                {
                    If ((I31E == One))
                    {
                        Return (0x0F)
                    }
                }

                Return (Zero)
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (I3A1, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((I31D && I31E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((I31D && I31E))
                {
                    DSAD (I3A1, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((I31D && I31E))
                {
                    DSAD (I3A1, 0x03)
                }
            }
        }

        Device (I3CC)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((I32M == Zero))
                {
                    If (CondRefOf (HCIB))
                    {
                        Return (HCID) /* \_SB_.HCID */
                    }
                    Else
                    {
                        Return (I3ID) /* \_SB_.I3ID */
                    }
                }
                Else
                {
                    Return (I2ID) /* \_SB_.I2ID */
                }
            }

            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x17)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x04, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x40, 0xDD,  // ......@.
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x79, 0x00         // .....y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IC2I /* \_SB_.IC2I */
                Return (BUF0) /* \_SB_.I3CC._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (CondRefOf (I32I, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return (Zero)
                    }
                }

                If ((TSOS >= 0x70))
                {
                    If ((I32E == One))
                    {
                        Return (0x0F)
                    }
                }

                Return (Zero)
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (I3A2, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((I32D && I32E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((I32D && I32E))
                {
                    DSAD (I3A2, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((I32D && I32E))
                {
                    DSAD (I3A2, 0x03)
                }
            }
        }

        Device (I3CD)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((I33M == Zero))
                {
                    If (CondRefOf (HCIB))
                    {
                        Return (HCID) /* \_SB_.HCID */
                    }
                    Else
                    {
                        Return (I3ID) /* \_SB_.I3ID */
                    }
                }
                Else
                {
                    Return (I2ID) /* \_SB_.I2ID */
                }
            }

            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x17)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x06, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x60, 0xDD,  // ......`.
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x79, 0x00         // .....y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IC3I /* \_SB_.IC3I */
                Return (BUF0) /* \_SB_.I3CD._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (CondRefOf (I33I, Local0))
                {
                    If ((DerefOf (Local0) == One))
                    {
                        Return (Zero)
                    }
                }

                If ((TSOS >= 0x70))
                {
                    If ((I33E == One))
                    {
                        Return (0x0F)
                    }
                }

                Return (Zero)
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (I3A3, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((I33D && I33E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((I33D && I33E))
                {
                    DSAD (I3A3, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((I33D && I33E))
                {
                    DSAD (I3A3, 0x03)
                }
            }
        }
    }

    Scope (_SB.I3CA)
    {
        Method (_DSD, 0, Serialized)  // _DSD: Device-Specific Data
        {
            If (CondRefOf (HCIB))
            {
                Return (Package (0x04)
                {
                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                    Package (0x02)
                    {
                        "mipi-i3c-sw-interface-revision", 
                        0x00010000
                    }, 

                    ToUUID ("dbb8e3e6-5886-4ba6-8795-1319f52a966b") /* Hierarchical Data Extension */, 
                    Package (0x02)
                    {
                        "mipi-i3c-ctrlr-0-subproperties", 
                        CTR0, 
                    }
                })
            }
        }

        Method (CTR0, 0, Serialized)
        {
            If (CondRefOf (HCIB))
            {
                Return (Package (0x02)
                {
                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                    Package (0x02)
                    {
                        "mipi-i3c-sw-interface-revision", 
                        0x00010000
                    }
                })
            }
        }
    }

    Scope (_SB.I3CB)
    {
        Method (_DSD, 0, Serialized)  // _DSD: Device-Specific Data
        {
            If (CondRefOf (HCIB))
            {
                Return (Package (0x04)
                {
                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                    Package (0x02)
                    {
                        "mipi-i3c-sw-interface-revision", 
                        0x00010000
                    }, 

                    ToUUID ("dbb8e3e6-5886-4ba6-8795-1319f52a966b") /* Hierarchical Data Extension */, 
                    Package (0x02)
                    {
                        "mipi-i3c-ctrlr-0-subproperties", 
                        CTR0, 
                    }
                })
            }
        }

        Method (CTR0, 0, Serialized)
        {
            If (CondRefOf (HCIB))
            {
                Return (Package (0x02)
                {
                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                    Package (0x02)
                    {
                        "mipi-i3c-sw-interface-revision", 
                        0x00010000
                    }
                })
            }
        }
    }

    Scope (_SB.I3CC)
    {
        Method (_DSD, 0, Serialized)  // _DSD: Device-Specific Data
        {
            If (CondRefOf (HCIB))
            {
                Return (Package (0x04)
                {
                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                    Package (0x02)
                    {
                        "mipi-i3c-sw-interface-revision", 
                        0x00010000
                    }, 

                    ToUUID ("dbb8e3e6-5886-4ba6-8795-1319f52a966b") /* Hierarchical Data Extension */, 
                    Package (0x02)
                    {
                        "mipi-i3c-ctrlr-0-subproperties", 
                        CTR0, 
                    }
                })
            }
        }

        Method (CTR0, 0, Serialized)
        {
            If (CondRefOf (HCIB))
            {
                Return (Package (0x02)
                {
                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                    Package (0x02)
                    {
                        "mipi-i3c-sw-interface-revision", 
                        0x00010000
                    }
                })
            }
        }
    }

    Scope (_SB.I3CD)
    {
        Method (_DSD, 0, Serialized)  // _DSD: Device-Specific Data
        {
            If (CondRefOf (HCIB))
            {
                Return (Package (0x04)
                {
                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                    Package (0x02)
                    {
                        "mipi-i3c-sw-interface-revision", 
                        0x00010000
                    }, 

                    ToUUID ("dbb8e3e6-5886-4ba6-8795-1319f52a966b") /* Hierarchical Data Extension */, 
                    Package (0x02)
                    {
                        "mipi-i3c-ctrlr-0-subproperties", 
                        CTR0, 
                    }
                })
            }
        }

        Method (CTR0, 0, Serialized)
        {
            If (CondRefOf (HCIB))
            {
                Return (Package (0x02)
                {
                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                    Package (0x02)
                    {
                        "mipi-i3c-sw-interface-revision", 
                        0x00010000
                    }
                })
            }
        }
    }

    Scope (_SB.PCI0)
    {
        Device (UAR1)
        {
            Name (_HID, EisaId ("PNP0500") /* Standard PC COM Serial Port */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Name (_DDN, "COM1")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (Zero)
                If ((Local1 != 0x0F))
                {
                    Local0 = 0x0F
                }

                If ((UL0I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x0D)
                {
                    /* 0000 */  0x47, 0x01, 0xE8, 0x02, 0xE8, 0x02, 0x01, 0x08,  // G.......
                    /* 0008 */  0x22, 0x08, 0x00, 0x79, 0x00                     // "..y.
                })
                CreateByteField (BUF0, 0x02, IOLO)
                CreateByteField (BUF0, 0x03, IOHI)
                CreateByteField (BUF0, 0x04, IORL)
                CreateByteField (BUF0, 0x05, IORH)
                CreateWordField (BUF0, 0x09, IRQL)
                Local0 = FUIO (Zero)
                Switch (ToInteger (Local0))
                {
                    Case (Zero)
                    {
                        IOLO = 0xE8
                        IOHI = 0x02
                        IORL = 0xE8
                        IORH = 0x02
                    }
                    Case (One)
                    {
                        IOLO = 0xF8
                        IOHI = 0x02
                        IORL = 0xF8
                        IORH = 0x02
                    }
                    Case (0x02)
                    {
                        IOLO = 0xE8
                        IOHI = 0x03
                        IORL = 0xE8
                        IORH = 0x03
                    }
                    Case (0x03)
                    {
                        IOLO = 0xF8
                        IOHI = 0x03
                        IORL = 0xF8
                        IORH = 0x03
                    }

                }

                IRQL = (One << (FRUI (Zero) & 0x0F))
                Return (BUF0) /* \_SB_.PCI0.UAR1._CRS.BUF0 */
            }
        }

        Device (UAR2)
        {
            Name (_HID, EisaId ("PNP0500") /* Standard PC COM Serial Port */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Name (_DDN, "COM2")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (One)
                If ((Local1 != 0x0F))
                {
                    Local0 = 0x0F
                }

                If ((UL1I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x0D)
                {
                    /* 0000 */  0x47, 0x01, 0xF8, 0x02, 0xF8, 0x02, 0x01, 0x08,  // G.......
                    /* 0008 */  0x22, 0x10, 0x00, 0x79, 0x00                     // "..y.
                })
                CreateByteField (BUF0, 0x02, IOLO)
                CreateByteField (BUF0, 0x03, IOHI)
                CreateByteField (BUF0, 0x04, IORL)
                CreateByteField (BUF0, 0x05, IORH)
                CreateWordField (BUF0, 0x09, IRQL)
                Local0 = FUIO (One)
                Switch (ToInteger (Local0))
                {
                    Case (Zero)
                    {
                        IOLO = 0xE8
                        IOHI = 0x02
                        IORL = 0xE8
                        IORH = 0x02
                    }
                    Case (One)
                    {
                        IOLO = 0xF8
                        IOHI = 0x02
                        IORL = 0xF8
                        IORH = 0x02
                    }
                    Case (0x02)
                    {
                        IOLO = 0xE8
                        IOHI = 0x03
                        IORL = 0xE8
                        IORH = 0x03
                    }
                    Case (0x03)
                    {
                        IOLO = 0xF8
                        IOHI = 0x03
                        IORL = 0xF8
                        IORH = 0x03
                    }

                }

                IRQL = (One << (FRUI (One) & 0x0F))
                Return (BUF0) /* \_SB_.PCI0.UAR2._CRS.BUF0 */
            }
        }

        Device (UAR3)
        {
            Name (_HID, EisaId ("PNP0500") /* Standard PC COM Serial Port */)  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Name (_DDN, "COM3")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (0x02)
                If ((Local1 != 0x0F))
                {
                    Local0 = 0x0F
                }

                If ((UL2I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x0D)
                {
                    /* 0000 */  0x47, 0x01, 0xE8, 0x03, 0xE8, 0x03, 0x01, 0x08,  // G.......
                    /* 0008 */  0x22, 0x08, 0x00, 0x79, 0x00                     // "..y.
                })
                CreateByteField (BUF0, 0x02, IOLO)
                CreateByteField (BUF0, 0x03, IOHI)
                CreateByteField (BUF0, 0x04, IORL)
                CreateByteField (BUF0, 0x05, IORH)
                CreateWordField (BUF0, 0x09, IRQL)
                Local0 = FUIO (0x02)
                Switch (ToInteger (Local0))
                {
                    Case (Zero)
                    {
                        IOLO = 0xE8
                        IOHI = 0x02
                        IORL = 0xE8
                        IORH = 0x02
                    }
                    Case (One)
                    {
                        IOLO = 0xF8
                        IOHI = 0x02
                        IORL = 0xF8
                        IORH = 0x02
                    }
                    Case (0x02)
                    {
                        IOLO = 0xE8
                        IOHI = 0x03
                        IORL = 0xE8
                        IORH = 0x03
                    }
                    Case (0x03)
                    {
                        IOLO = 0xF8
                        IOHI = 0x03
                        IORL = 0xF8
                        IORH = 0x03
                    }

                }

                IRQL = (One << (FRUI (0x02) & 0x0F))
                Return (BUF0) /* \_SB_.PCI0.UAR3._CRS.BUF0 */
            }
        }

        Device (UAR4)
        {
            Name (_HID, EisaId ("PNP0500") /* Standard PC COM Serial Port */)  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
            Name (_DDN, "COM4")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (0x03)
                If ((Local1 != 0x0F))
                {
                    Local0 = 0x0F
                }

                If ((UL3I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x0D)
                {
                    /* 0000 */  0x47, 0x01, 0xF8, 0x03, 0xF8, 0x03, 0x01, 0x08,  // G.......
                    /* 0008 */  0x22, 0x10, 0x00, 0x79, 0x00                     // "..y.
                })
                CreateByteField (BUF0, 0x02, IOLO)
                CreateByteField (BUF0, 0x03, IOHI)
                CreateByteField (BUF0, 0x04, IORL)
                CreateByteField (BUF0, 0x05, IORH)
                CreateWordField (BUF0, 0x09, IRQL)
                Local0 = FUIO (0x03)
                Switch (ToInteger (Local0))
                {
                    Case (Zero)
                    {
                        IOLO = 0xE8
                        IOHI = 0x02
                        IORL = 0xE8
                        IORH = 0x02
                    }
                    Case (One)
                    {
                        IOLO = 0xF8
                        IOHI = 0x02
                        IORL = 0xF8
                        IORH = 0x02
                    }
                    Case (0x02)
                    {
                        IOLO = 0xE8
                        IOHI = 0x03
                        IORL = 0xE8
                        IORH = 0x03
                    }
                    Case (0x03)
                    {
                        IOLO = 0xF8
                        IOHI = 0x03
                        IORL = 0xF8
                        IORH = 0x03
                    }

                }

                IRQL = (One << (FRUI (0x03) & 0x0F))
                Return (BUF0) /* \_SB_.PCI0.UAR4._CRS.BUF0 */
            }
        }
    }

    Scope (_SB.I2CA)
    {
        Device (NFC1)
        {
            Name (_HID, EisaId ("NXP8013"))  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x87)
                {
                    /* 0000 */  0x8E, 0x19, 0x00, 0x01, 0x00, 0x01, 0x02, 0x00,  // ........
                    /* 0008 */  0x00, 0x01, 0x06, 0x00, 0x80, 0x1A, 0x06, 0x00,  // ........
                    /* 0010 */  0x29, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x49,  // ).\_SB.I
                    /* 0018 */  0x32, 0x43, 0x41, 0x00, 0x8C, 0x20, 0x00, 0x01,  // 2CA.. ..
                    /* 0020 */  0x00, 0x01, 0x00, 0x12, 0x00, 0x03, 0x00, 0x00,  // ........
                    /* 0028 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
                    /* 0030 */  0x00, 0x00, 0x00, 0x5B, 0x00, 0x5C, 0x5F, 0x53,  // ...[.\_S
                    /* 0038 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x8C,  // B.GPIO..
                    /* 0040 */  0x20, 0x00, 0x01, 0x01, 0x01, 0x00, 0x02, 0x00,  //  .......
                    /* 0048 */  0x03, 0x00, 0x00, 0x00, 0x00, 0x17, 0x00, 0x00,  // ........
                    /* 0050 */  0x19, 0x00, 0x23, 0x00, 0x00, 0x00, 0x4A, 0x00,  // ..#...J.
                    /* 0058 */  0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x47, 0x50, 0x49,  // \_SB.GPI
                    /* 0060 */  0x4F, 0x00, 0x8C, 0x20, 0x00, 0x01, 0x01, 0x01,  // O.. ....
                    /* 0068 */  0x00, 0x02, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0070 */  0x17, 0x00, 0x00, 0x19, 0x00, 0x23, 0x00, 0x00,  // .....#..
                    /* 0078 */  0x00, 0x90, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E,  // ...\_SB.
                    /* 0080 */  0x47, 0x50, 0x49, 0x4F, 0x00, 0x79, 0x00         // GPIO.y.
                })
                Return (RBUF) /* \_SB_.I2CA.NFC1._CRS.RBUF */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (((TPOS >= 0x60) & (NFCS == Zero)))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }

    Scope (_SB.I2CB)
    {
        Device (NFC1)
        {
            Name (_HID, EisaId ("NXP8013"))  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x87)
                {
                    /* 0000 */  0x8E, 0x19, 0x00, 0x01, 0x00, 0x01, 0x02, 0x00,  // ........
                    /* 0008 */  0x00, 0x01, 0x06, 0x00, 0x80, 0x1A, 0x06, 0x00,  // ........
                    /* 0010 */  0x29, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x49,  // ).\_SB.I
                    /* 0018 */  0x32, 0x43, 0x42, 0x00, 0x8C, 0x20, 0x00, 0x01,  // 2CB.. ..
                    /* 0020 */  0x00, 0x01, 0x00, 0x12, 0x00, 0x03, 0x00, 0x00,  // ........
                    /* 0028 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
                    /* 0030 */  0x00, 0x00, 0x00, 0x5B, 0x00, 0x5C, 0x5F, 0x53,  // ...[.\_S
                    /* 0038 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x8C,  // B.GPIO..
                    /* 0040 */  0x20, 0x00, 0x01, 0x01, 0x01, 0x00, 0x02, 0x00,  //  .......
                    /* 0048 */  0x03, 0x00, 0x00, 0x00, 0x00, 0x17, 0x00, 0x00,  // ........
                    /* 0050 */  0x19, 0x00, 0x23, 0x00, 0x00, 0x00, 0x4A, 0x00,  // ..#...J.
                    /* 0058 */  0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x47, 0x50, 0x49,  // \_SB.GPI
                    /* 0060 */  0x4F, 0x00, 0x8C, 0x20, 0x00, 0x01, 0x01, 0x01,  // O.. ....
                    /* 0068 */  0x00, 0x02, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0070 */  0x17, 0x00, 0x00, 0x19, 0x00, 0x23, 0x00, 0x00,  // .....#..
                    /* 0078 */  0x00, 0x90, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E,  // ...\_SB.
                    /* 0080 */  0x47, 0x50, 0x49, 0x4F, 0x00, 0x79, 0x00         // GPIO.y.
                })
                Return (RBUF) /* \_SB_.I2CB.NFC1._CRS.RBUF */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (((TPOS >= 0x60) & (NFCS == One)))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }

    Scope (_SB.I2CC)
    {
        Device (NFC1)
        {
            Name (_HID, EisaId ("NXP8013"))  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x87)
                {
                    /* 0000 */  0x8E, 0x19, 0x00, 0x01, 0x00, 0x01, 0x02, 0x00,  // ........
                    /* 0008 */  0x00, 0x01, 0x06, 0x00, 0x80, 0x1A, 0x06, 0x00,  // ........
                    /* 0010 */  0x29, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x49,  // ).\_SB.I
                    /* 0018 */  0x32, 0x43, 0x43, 0x00, 0x8C, 0x20, 0x00, 0x01,  // 2CC.. ..
                    /* 0020 */  0x00, 0x01, 0x00, 0x12, 0x00, 0x03, 0x00, 0x00,  // ........
                    /* 0028 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
                    /* 0030 */  0x00, 0x00, 0x00, 0x5B, 0x00, 0x5C, 0x5F, 0x53,  // ...[.\_S
                    /* 0038 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x8C,  // B.GPIO..
                    /* 0040 */  0x20, 0x00, 0x01, 0x01, 0x01, 0x00, 0x02, 0x00,  //  .......
                    /* 0048 */  0x03, 0x00, 0x00, 0x00, 0x00, 0x17, 0x00, 0x00,  // ........
                    /* 0050 */  0x19, 0x00, 0x23, 0x00, 0x00, 0x00, 0x4A, 0x00,  // ..#...J.
                    /* 0058 */  0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x47, 0x50, 0x49,  // \_SB.GPI
                    /* 0060 */  0x4F, 0x00, 0x8C, 0x20, 0x00, 0x01, 0x01, 0x01,  // O.. ....
                    /* 0068 */  0x00, 0x02, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0070 */  0x17, 0x00, 0x00, 0x19, 0x00, 0x23, 0x00, 0x00,  // .....#..
                    /* 0078 */  0x00, 0x90, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E,  // ...\_SB.
                    /* 0080 */  0x47, 0x50, 0x49, 0x4F, 0x00, 0x79, 0x00         // GPIO.y.
                })
                Return (RBUF) /* \_SB_.I2CC.NFC1._CRS.RBUF */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (((TPOS >= 0x60) & (NFCS == 0x02)))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }

    Scope (_SB.I2CD)
    {
        Device (NFC1)
        {
            Name (_HID, EisaId ("NXP8013"))  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x87)
                {
                    /* 0000 */  0x8E, 0x19, 0x00, 0x01, 0x00, 0x01, 0x02, 0x00,  // ........
                    /* 0008 */  0x00, 0x01, 0x06, 0x00, 0x80, 0x1A, 0x06, 0x00,  // ........
                    /* 0010 */  0x29, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x49,  // ).\_SB.I
                    /* 0018 */  0x32, 0x43, 0x44, 0x00, 0x8C, 0x20, 0x00, 0x01,  // 2CD.. ..
                    /* 0020 */  0x00, 0x01, 0x00, 0x12, 0x00, 0x03, 0x00, 0x00,  // ........
                    /* 0028 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
                    /* 0030 */  0x00, 0x00, 0x00, 0x5B, 0x00, 0x5C, 0x5F, 0x53,  // ...[.\_S
                    /* 0038 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x8C,  // B.GPIO..
                    /* 0040 */  0x20, 0x00, 0x01, 0x01, 0x01, 0x00, 0x02, 0x00,  //  .......
                    /* 0048 */  0x03, 0x00, 0x00, 0x00, 0x00, 0x17, 0x00, 0x00,  // ........
                    /* 0050 */  0x19, 0x00, 0x23, 0x00, 0x00, 0x00, 0x4A, 0x00,  // ..#...J.
                    /* 0058 */  0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x47, 0x50, 0x49,  // \_SB.GPI
                    /* 0060 */  0x4F, 0x00, 0x8C, 0x20, 0x00, 0x01, 0x01, 0x01,  // O.. ....
                    /* 0068 */  0x00, 0x02, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0070 */  0x17, 0x00, 0x00, 0x19, 0x00, 0x23, 0x00, 0x00,  // .....#..
                    /* 0078 */  0x00, 0x90, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E,  // ...\_SB.
                    /* 0080 */  0x47, 0x50, 0x49, 0x4F, 0x00, 0x79, 0x00         // GPIO.y.
                })
                Return (RBUF) /* \_SB_.I2CD.NFC1._CRS.RBUF */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (((TPOS >= 0x60) & (NFCS == 0x03)))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }

    Method (SPTS, 1, NotSerialized)
    {
        CLPS = One
        SLPS = One
        PEWS = Zero
    }

    Method (SWAK, 1, NotSerialized)
    {
        PEWS = Zero
        PEWD = Zero
        If (PICM)
        {
            \_SB.DSPI ()
        }

        If (TMSE)
        {
            TMSE = Zero
        }

        If (((Arg0 == 0x03) || (Arg0 == 0x04)))
        {
            If ((\_SB.APBM == One))
            {
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }
        }
    }

    Device (_SB.TPM)
    {
        Name (TMRQ, 0xFFFFFFFF)
        Name (TLVL, 0xFFFFFFFF)
        Name (HPMB, 0xFE008000)
        Name (HPML, 0x00001000)
        Name (ITRV, 0xFFFFFFFF)
        Name (ILVV, 0xFFFFFFFF)
        Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
        {
            If (TCMF)
            {
                Return (0x01013469)
            }
            ElseIf ((TTDP == Zero))
            {
                Return (0x310CD041)
            }
            Else
            {
                Return ("MSFT0101")
            }
        }

        OperationRegion (TMMB, SystemMemory, 0xFED40000, 0x5000)
        Field (TMMB, ByteAcc, Lock, Preserve)
        {
            ACC0,   8, 
            Offset (0x08), 
            INTE,   32, 
            INTV,   8, 
            Offset (0x10), 
            INTS,   32, 
            INTF,   32, 
            TSTS,   32, 
            Offset (0x24), 
            FIFO,   32, 
            Offset (0x30), 
            IDTF,   32, 
            Offset (0x4C), 
            SCMD,   32
        }

        Method (_STR, 0, NotSerialized)  // _STR: Description String
        {
            If ((TTDP == Zero))
            {
                Return (Unicode ("TPM 1.2 Device"))
            }
            Else
            {
                Return (Unicode ("TPM 2.0 Device"))
            }
        }

        Name (_UID, One)  // _UID: Unique ID
        Name (CRST, Buffer (0x1A)
        {
            /* 0000 */  0x86, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
            /* 0008 */  0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00, 0x00,  // ........
            /* 0010 */  0x00, 0x00, 0xD7, 0xFE, 0x00, 0x10, 0x00, 0x00,  // ........
            /* 0018 */  0x79, 0x00                                       // y.
        })
        Name (CRSD, Buffer (0x0E)
        {
            /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xD4, 0xFE,  // ........
            /* 0008 */  0x00, 0x50, 0x00, 0x00, 0x79, 0x00               // .P..y.
        })
        Name (CRID, Buffer (0x0E)
        {
            /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xD4, 0xFE,  // ........
            /* 0008 */  0x00, 0x50, 0x00, 0x00, 0x79, 0x00               // .P..y.
        })
        Name (CREI, Buffer (0x31)
        {
            /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xD4, 0xFE,  // ........
            /* 0008 */  0x00, 0x50, 0x00, 0x00, 0x8C, 0x20, 0x00, 0x01,  // .P... ..
            /* 0010 */  0x00, 0x01, 0x00, 0x12, 0x00, 0x03, 0x00, 0x00,  // ........
            /* 0018 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
            /* 0020 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x5C, 0x5F, 0x53,  // .....\_S
            /* 0028 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x79,  // B.GPIO.y
            /* 0030 */  0x00                                             // .
        })
        Name (CRSI, Buffer (0x0E)
        {
            /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
            /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x79, 0x00               // ....y.
        })
        Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
        {
            If ((AMDT == One))
            {
                CreateDWordField (CRST, 0x04, MTFB)
                CreateDWordField (CRST, 0x08, LTFB)
                MTFB = TPMB /* \TPMB */
                LTFB = TPBS /* \TPBS */
                CreateDWordField (CRST, 0x10, MTFC)
                CreateDWordField (CRST, 0x14, LTFC)
                MTFC = TPMC /* \TPMC */
                LTFC = TPCS /* \TPCS */
                Return (CRST) /* \_SB_.TPM_.CRST */
            }
            Else
            {
                If ((DTPT == One))
                {
                    CreateDWordField (CRSD, 0x04, MTFE)
                    CreateDWordField (CRSD, 0x08, LTFE)
                    MTFE = 0xFED40000
                    LTFE = 0x5000
                    Return (CRSD) /* \_SB_.TPM_.CRSD */
                }
                ElseIf ((TTPF == One))
                {
                    If (((TMRQ == Zero) || (TMRQ == 0xFFFFFFFF)))
                    {
                        CreateDWordField (CRID, 0x04, MTFD)
                        CreateDWordField (CRID, 0x08, LTFD)
                        MTFD = 0xFED40000
                        LTFD = 0x5000
                        Return (CRID) /* \_SB_.TPM_.CRID */
                    }
                    Else
                    {
                        CreateWordField (CREI, 0x23, LIRQ)
                        CreateBitField (CREI, 0x99, LLVL)
                        LIRQ = TMRQ /* \_SB_.TPM_.TMRQ */
                        LLVL = TLVL /* \_SB_.TPM_.TLVL */
                        Return (CREI) /* \_SB_.TPM_.CREI */
                    }
                }
                ElseIf ((TTPF == Zero))
                {
                    If ((AMDT == 0x02))
                    {
                        If (((HPMB != Zero) && (HPMB != 0xFFFFFFFF)))
                        {
                            CreateDWordField (CRSI, 0x04, HSPB)
                            CreateDWordField (CRSI, 0x08, HSPL)
                            HSPB = HPMB /* \_SB_.TPM_.HPMB */
                            HSPL = HPML /* \_SB_.TPM_.HPML */
                        }

                        Return (CRSI) /* \_SB_.TPM_.CRSI */
                    }

                    CreateDWordField (CRST, 0x10, MTFF)
                    MTFF = FTPM /* \FTPM */
                    Return (CRST) /* \_SB_.TPM_.CRST */
                }

                MTFE = Zero
                LTFE = Zero
                Return (CRID) /* \_SB_.TPM_.CRID */
            }

            Return (CRID) /* \_SB_.TPM_.CRID */
        }

        Method (_SRS, 1, Serialized)  // _SRS: Set Resource Settings
        {
            If (((TMRQ != Zero) && (TMRQ != 0xFFFFFFFF)))
            {
                If ((AMDT == 0x02)){}
                Else
                {
                    CreateWordField (Arg0, 0x23, IRQ0)
                    CreateWordField (CREI, 0x23, LIRQ)
                    LIRQ = IRQ0 /* \_SB_.TPM_._SRS.IRQ0 */
                    TMRQ = IRQ0 /* \_SB_.TPM_._SRS.IRQ0 */
                    CreateBitField (Arg0, 0x98, ITRG)
                    CreateBitField (CREI, 0x98, LTRG)
                    LTRG = ITRG /* \_SB_.TPM_._SRS.ITRG */
                    ITRV = ITRG /* \_SB_.TPM_._SRS.ITRG */
                    CreateBitField (Arg0, 0x99, ILVL)
                    CreateBitField (CREI, 0x99, LLVL)
                    LLVL = ILVL /* \_SB_.TPM_._SRS.ILVL */
                    ILVV = ILVL /* \_SB_.TPM_._SRS.ILVL */
                }

                If ((((IDTF & 0x0F) == Zero) || ((IDTF & 0x0F
                    ) == 0x0F)))
                {
                    If ((IRQ0 < 0x10))
                    {
                        INTV = (IRQ0 & 0x0F)
                    }

                    If ((ITRV == One))
                    {
                        INTE |= 0x10
                    }
                    Else
                    {
                        INTE &= 0xFFFFFFEF
                    }

                    If ((ILVV == Zero))
                    {
                        INTE |= 0x08
                    }
                    Else
                    {
                        INTE &= 0xFFFFFFF7
                    }
                }
            }
        }

        OperationRegion (CRBD, SystemMemory, TPMM, 0x48)
        Field (CRBD, AnyAcc, NoLock, Preserve)
        {
            Offset (0x04), 
            HERR,   32, 
            Offset (0x40), 
            HCMD,   32, 
            Offset (0x44), 
            HSTS,   32
        }

        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If ((TTDP == Zero))
            {
                If (TPMF)
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
            ElseIf ((TTDP == One))
            {
                If (TPMF)
                {
                    Return (0x0F)
                }

                Return (Zero)
            }

            Return (Zero)
        }

        Method (STRT, 3, Serialized)
        {
            OperationRegion (TPMR, SystemMemory, FTPM, 0x1000)
            Field (TPMR, AnyAcc, NoLock, Preserve)
            {
                Offset (0x04), 
                FERR,   32, 
                Offset (0x0C), 
                BEGN,   32
            }

            Name (TIMR, Zero)
            If ((ToInteger (Arg0) != Zero)){}
            Switch (ToInteger (Arg1))
            {
                Case (Zero)
                {
                    Return (Buffer (One)
                    {
                         0x03                                             // .
                    })
                }
                Case (One)
                {
                    TIMR = Zero
                    If ((AMDT == One))
                    {
                        While (((BEGN == One) && (TIMR < 0x0200)))
                        {
                            If ((BEGN == One))
                            {
                                Sleep (One)
                                TIMR++
                            }
                        }
                    }
                    ElseIf ((((HSTS & 0x02) | (HSTS & One)
                        ) == 0x03))
                    {
                        HCMD = One
                    }
                    Else
                    {
                        FERR = One
                        BEGN = Zero
                    }

                    Return (Zero)
                }

            }

            Return (One)
        }

        Method (CRYF, 3, Serialized)
        {
            If ((ToInteger (Arg0) != One)){}
            Switch (ToInteger (Arg1))
            {
                Case (Zero)
                {
                    Return (Buffer (One)
                    {
                         0x03                                             // .
                    })
                }
                Case (One)
                {
                    Name (TPMV, Package (0x02)
                    {
                        One, 
                        Package (0x02)
                        {
                            One, 
                            0x20
                        }
                    })
                    If ((_STA () == Zero))
                    {
                        Return (Package (0x01)
                        {
                            Zero
                        })
                    }

                    Return (TPMV) /* \_SB_.TPM_.CRYF.TPMV */
                }

            }

            Return (Buffer (One)
            {
                 0x00                                             // .
            })
        }
    }

    Scope (_SB.TPM)
    {
        OperationRegion (TSMI, SystemIO, SMIA, 0x02)
        Field (TSMI, WordAcc, NoLock, Preserve)
        {
            SMI,    16
        }

        OperationRegion (ATNV, SystemMemory, PPIM, PPIL)
        Field (ATNV, AnyAcc, NoLock, Preserve)
        {
            RQST,   32, 
            RCNT,   32, 
            ERRO,   32, 
            FLAG,   32, 
            MISC,   32, 
            OPTN,   32, 
            SRSP,   32
        }

        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            If ((Arg0 == ToUUID ("3dddfaa6-361b-4eb4-a424-8d10089d1653") /* Physical Presence Interface */))
            {
                Switch (ToInteger (Arg2))
                {
                    Case (Zero)
                    {
                        Return (Buffer (0x02)
                        {
                             0xFF, 0x01                                       // ..
                        })
                    }
                    Case (One)
                    {
                        If ((PPIV == Zero))
                        {
                            Return ("1.2")
                        }
                        Else
                        {
                            Return ("1.3")
                        }
                    }
                    Case (0x02)
                    {
                        RQST = DerefOf (Arg3 [Zero])
                        SRSP = Zero
                        FLAG = 0x02
                        TMF1 = OFST /* \OFST */
                        SRSP = Zero
                        SMI = TMF1 /* \TMF1 */
                        Return (SRSP) /* \_SB_.TPM_.SRSP */
                    }
                    Case (0x03)
                    {
                        Name (PPI1, Package (0x02)
                        {
                            Zero, 
                            Zero
                        })
                        PPI1 [One] = RQST /* \_SB_.TPM_.RQST */
                        Return (PPI1) /* \_SB_.TPM_._DSM.PPI1 */
                    }
                    Case (0x04)
                    {
                        Return (TRST) /* \TRST */
                    }
                    Case (0x05)
                    {
                        Name (PPI2, Package (0x03)
                        {
                            Zero, 
                            Zero, 
                            Zero
                        })
                        SRSP = Zero
                        FLAG = 0x05
                        SMI = OFST /* \OFST */
                        PPI2 [One] = RCNT /* \_SB_.TPM_.RCNT */
                        PPI2 [0x02] = ERRO /* \_SB_.TPM_.ERRO */
                        Return (PPI2) /* \_SB_.TPM_._DSM.PPI2 */
                    }
                    Case (0x06)
                    {
                        Return (0x03)
                    }
                    Case (0x07)
                    {
                        RQST = DerefOf (Arg3 [Zero])
                        FLAG = 0x07
                        OPTN = Zero
                        If ((RQST == 0x17))
                        {
                            ToInteger (DerefOf (Arg3 [One]), OPTN) /* \_SB_.TPM_.OPTN */
                        }

                        TMF1 = OFST /* \OFST */
                        SRSP = Zero
                        SMI = TMF1 /* \TMF1 */
                        Return (SRSP) /* \_SB_.TPM_.SRSP */
                    }
                    Case (0x08)
                    {
                        RQST = DerefOf (Arg3 [Zero])
                        FLAG = 0x08
                        TMF1 = OFST /* \OFST */
                        SRSP = Zero
                        SMI = TMF1 /* \TMF1 */
                        Return (SRSP) /* \_SB_.TPM_.SRSP */
                    }
                    Default
                    {
                    }

                }
            }
            ElseIf ((Arg0 == ToUUID ("376054ed-cc13-4675-901c-4756d7f2d45d") /* TPM Memory Clear */))
            {
                Switch (ToInteger (Arg2))
                {
                    Case (Zero)
                    {
                        Return (Buffer (One)
                        {
                             0x03                                             // .
                        })
                    }
                    Case (One)
                    {
                        RQST = DerefOf (Arg3 [Zero])
                        FLAG = 0x09
                        TMF1 = OFST /* \OFST */
                        SRSP = Zero
                        SMI = TMF1 /* \TMF1 */
                        Return (SRSP) /* \_SB_.TPM_.SRSP */
                    }
                    Default
                    {
                    }

                }
            }

            If ((Arg0 == ToUUID ("cf8e16a5-c1e8-4e25-b712-4f54a96702c8") /* TPM Hardware Information */))
            {
                Return (CRYF (Arg1, Arg2, Arg3))
            }

            If ((Arg0 == ToUUID ("6bbf6cab-5463-4714-b7cd-f0203c0368d4") /* TPM Start Method */))
            {
                Return (STRT (Arg1, Arg2, Arg3))
            }

            Return (Buffer (One)
            {
                 0x00                                             // .
            })
        }

        Method (TPTS, 1, Serialized)
        {
            Switch (ToInteger (Arg0))
            {
                Case (0x04)
                {
                    RQST = Zero
                    FLAG = 0x09
                    SRSP = Zero
                    SMI = OFST /* \OFST */
                }
                Case (0x05)
                {
                    RQST = Zero
                    FLAG = 0x09
                    SRSP = Zero
                    SMI = OFST /* \OFST */
                }

            }

            Sleep (0x012C)
        }
    }

    Scope (_SB.PCI0.GPPA.PSP)
    {
        Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
        Name (PSPB, 0xFD300000)
        Name (PSPL, 0x00100000)
        Name (_STA, 0x0F)  // _STA: Status
        Name (CRS, Buffer (0x0E)
        {
            /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
            /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x79, 0x00               // ....y.
        })
        Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
        {
            CreateDWordField (CRS, 0x04, PBAS)
            CreateDWordField (CRS, 0x08, PLEN)
            PBAS = PSPB /* \_SB_.PCI0.GPPA.PSP_.PSPB */
            PLEN = PSPL /* \_SB_.PCI0.GPPA.PSP_.PSPL */
            Return (CRS) /* \_SB_.PCI0.GPPA.PSP_.CRS_ */
        }
    }

    Scope (_SB)
    {
        Device (ACDC)
        {
            Name (_HID, "ACPI000E" /* Time and Alarm Device */)  // _HID: Hardware ID
            Name (_CRS, Buffer (0x25)  // _CRS: Current Resource Settings
            {
                /* 0000 */  0x8C, 0x20, 0x00, 0x01, 0x00, 0x01, 0x00, 0x1B,  // . ......
                /* 0008 */  0x00, 0x01, 0x00, 0x00, 0xB8, 0x0B, 0x17, 0x00,  // ........
                /* 0010 */  0x00, 0x19, 0x00, 0x23, 0x00, 0x00, 0x00, 0x34,  // ...#...4
                /* 0018 */  0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x47, 0x50,  // .\_SB.GP
                /* 0020 */  0x49, 0x4F, 0x00, 0x79, 0x00                     // IO.y.
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((PIOS >= 0x00201901))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            OperationRegion (IOMX, SystemMemory, 0xFED80D00, 0x0100)
            Field (IOMX, AnyAcc, NoLock, Preserve)
            {
                Offset (0x17), 
                IM17,   8
            }

            OperationRegion (CMOP, SystemMemory, 0xFED81D00, 0x0100)
            Field (CMOP, DWordAcc, NoLock, Preserve)
            {
                Offset (0x00), 
                ATVE,   32, 
                AETP,   32, 
                ATED,   1, 
                ATWP,   1, 
                Offset (0x10), 
                DTVE,   32, 
                DETP,   32, 
                DTED,   1, 
                DTWP,   1, 
                Offset (0x20), 
                BUSY,   1, 
                Offset (0x21), 
                ATEE,   1, 
                DTEE,   1
            }

            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                IM17 = Zero
                ATEE = One
                DTEE = One
            }

            Method (AINI, 0, NotSerialized)
            {
                IM17 = Zero
                ATEE = One
            }

            Method (DINI, 0, NotSerialized)
            {
                IM17 = Zero
                DTEE = One
            }

            Method (_STP, 2, NotSerialized)  // _STP: Set Expired Timer Wake Policy
            {
                If ((Arg0 == Zero))
                {
                    AETP = Arg1
                }
                Else
                {
                    DETP = Arg1
                }

                Return (Zero)
            }

            Method (_TIP, 1, NotSerialized)  // _TIP: Expired Timer Wake Policy
            {
                If ((Arg0 == One))
                {
                    Local0 = DETP /* \_SB_.ACDC.DETP */
                }
                Else
                {
                    Local0 = AETP /* \_SB_.ACDC.AETP */
                }

                Return (Local0)
            }

            Method (_STV, 2, NotSerialized)  // _STV: Set Timer Value
            {
                If ((Arg0 == Zero))
                {
                    AINI ()
                    ATVE = Arg1
                }
                Else
                {
                    DINI ()
                    DTVE = Arg1
                }

                Return (Zero)
            }

            Method (_TIV, 1, NotSerialized)  // _TIV: Timer Values
            {
                If ((Arg0 == One))
                {
                    Local0 = DTVE /* \_SB_.ACDC.DTVE */
                }
                Else
                {
                    Local0 = ATVE /* \_SB_.ACDC.ATVE */
                }

                Return (Local0)
            }

            Method (_GWS, 1, NotSerialized)  // _GWS: Get Wake Status
            {
                If ((Arg0 == One))
                {
                    Local0 = DTWP /* \_SB_.ACDC.DTWP */
                }
                Else
                {
                    Local0 = ATWP /* \_SB_.ACDC.ATWP */
                }

                Return (Local0)
            }

            Method (_CWS, 1, NotSerialized)  // _CWS: Clear Wake Alarm Status
            {
                If ((Arg0 == Zero))
                {
                    ATWP = One
                }
                Else
                {
                    DTWP = One
                }

                Return (Zero)
            }

            Name (TMZN, 0x07FF)
            Name (DAYL, Zero)
            Name (ATBF, 0x97B28498)
            Name (BUFU, One)
            Mutex (RTCL, 0x00)
            OperationRegion (ASMI, SystemIO, SMIO, One)
            Field (ASMI, ByteAcc, NoLock, Preserve)
            {
                INQ,    8
            }

            OperationRegion (DSMI, SystemMemory, ATBF, 0x04)
            Field (DSMI, AnyAcc, NoLock, Preserve)
            {
                BSTA,   8, 
                BDLY,   8, 
                BTZN,   16
            }

            OperationRegion (VRTC, SystemCMOS, Zero, 0x10)
            Field (VRTC, ByteAcc, Lock, Preserve)
            {
                SEC,    8, 
                SECA,   8, 
                MIN,    8, 
                MINA,   8, 
                HOR,    8, 
                HORA,   8, 
                DAYW,   8, 
                DAY,    8, 
                MON,    8, 
                YEAR,   8, 
                STAA,   8, 
                STAB,   8, 
                STAC,   8, 
                STAD,   8
            }

            Method (RTWT, 0, NotSerialized)
            {
                Acquire (RTCL, 0x07D0)
                While (((STAC & 0x10) != 0x10))
                {
                    Noop
                }

                Release (RTCL)
                Return (One)
            }

            Method (_GCP, 0, NotSerialized)  // _GCP: Get Capabilities
            {
                Return (0x07)
            }

            Method (_GRT, 0, Serialized)  // _GRT: Get Real Time
            {
                Name (RBUF, Buffer (0x10)
                {
                    /* 0000 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   // ........
                })
                CreateWordField (RBUF, Zero, TYAR)
                CreateByteField (RBUF, 0x02, TMON)
                CreateByteField (RBUF, 0x03, TDAY)
                CreateByteField (RBUF, 0x04, THOR)
                CreateByteField (RBUF, 0x05, TMIN)
                CreateByteField (RBUF, 0x06, TSEC)
                CreateByteField (RBUF, 0x07, TVAL)
                CreateWordField (RBUF, 0x0A, TZN)
                CreateByteField (RBUF, 0x0C, DYL)
                If (BUFU)
                {
                    BSTA = One
                    INQ = ATAA /* \ATAA */
                    Sleep (0x64)
                    If ((BSTA == 0x03))
                    {
                        DAYL = BDLY /* \_SB_.ACDC.BDLY */
                        TMZN = BTZN /* \_SB_.ACDC.BTZN */
                    }
                    Else
                    {
                        TMZN = 0x07FF
                        DAYL = Zero
                    }
                }

                RTWT ()
                FromBCD (YEAR, TYAR) /* \_SB_.ACDC._GRT.TYAR */
                FromBCD (MON, TMON) /* \_SB_.ACDC._GRT.TMON */
                FromBCD (DAY, TDAY) /* \_SB_.ACDC._GRT.TDAY */
                FromBCD (HOR, THOR) /* \_SB_.ACDC._GRT.THOR */
                FromBCD (MIN, TMIN) /* \_SB_.ACDC._GRT.TMIN */
                FromBCD (SEC, TSEC) /* \_SB_.ACDC._GRT.TSEC */
                TMZN = 0x07FF
                TZN = TMZN /* \_SB_.ACDC.TMZN */
                DYL = DAYL /* \_SB_.ACDC.DAYL */
                TYAR += 0x07D0
                TVAL = One
                Return (RBUF) /* \_SB_.ACDC._GRT.RBUF */
            }

            Method (_SRT, 1, Serialized)  // _SRT: Set Real Time
            {
                CreateWordField (Arg0, Zero, TYAR)
                CreateByteField (Arg0, 0x02, TMON)
                CreateByteField (Arg0, 0x03, TDAY)
                CreateByteField (Arg0, 0x04, THOR)
                CreateByteField (Arg0, 0x05, TMIN)
                CreateByteField (Arg0, 0x06, TSEC)
                CreateWordField (Arg0, 0x0A, TZN)
                CreateByteField (Arg0, 0x0C, DYL)
                If (BUFU)
                {
                    BSTA = 0x02
                    BDLY = DYL /* \_SB_.ACDC._SRT.DYL_ */
                    BTZN = TZN /* \_SB_.ACDC._SRT.TZN_ */
                    INQ = ATAA /* \ATAA */
                }

                RTWT ()
                ToBCD ((TYAR - 0x07D0), YEAR) /* \_SB_.ACDC.YEAR */
                ToBCD (TMON, MON) /* \_SB_.ACDC.MON_ */
                ToBCD (TDAY, DAY) /* \_SB_.ACDC.DAY_ */
                ToBCD (THOR, HOR) /* \_SB_.ACDC.HOR_ */
                ToBCD (TMIN, MIN) /* \_SB_.ACDC.MIN_ */
                ToBCD (TSEC, SEC) /* \_SB_.ACDC.SEC_ */
                TMZN = TZN /* \_SB_.ACDC._SRT.TZN_ */
                DAYL = DYL /* \_SB_.ACDC._SRT.DYL_ */
                If ((BSTA == 0x03))
                {
                    Return (Zero)
                }

                Return (0xFFFFFFFF)
            }
        }
    }

    Scope (_SB)
    {
        Device (WMTK)
        {
            Name (_HID, "PNP0C14" /* Windows Management Instrumentation Device */)  // _HID: Hardware ID
            Name (_UID, "SarDev")  // _UID: Unique ID
            Name (_WDG, Buffer (0x3C)
            {
                /* 0000 */  0xD4, 0x6E, 0x52, 0xB2, 0x45, 0xCB, 0xFA, 0x49,  // .nR.E..I
                /* 0008 */  0x92, 0x30, 0x8D, 0x2F, 0xE8, 0xAF, 0xB8, 0xEC,  // .0./....
                /* 0010 */  0x4D, 0x4B, 0x01, 0x02, 0xA0, 0x0D, 0x2A, 0x1E,  // MK....*.
                /* 0018 */  0x9E, 0x2B, 0x4F, 0x42, 0x9C, 0x87, 0xB1, 0xDA,  // .+OB....
                /* 0020 */  0xC3, 0xF4, 0xE9, 0xDA, 0xB0, 0x00, 0x01, 0x08,  // ........
                /* 0028 */  0x21, 0x12, 0x90, 0x05, 0x66, 0xD5, 0xD1, 0x11,  // !...f...
                /* 0030 */  0xB2, 0xF0, 0x00, 0xA0, 0xC9, 0x06, 0x29, 0x10,  // ......).
                /* 0038 */  0x4D, 0x4D, 0x01, 0x00                           // MM..
            })
            Name (WQMM, Buffer (0x056B)
            {
                /* 0000 */  0x46, 0x4F, 0x4D, 0x42, 0x01, 0x00, 0x00, 0x00,  // FOMB....
                /* 0008 */  0x5B, 0x05, 0x00, 0x00, 0x2C, 0x1C, 0x00, 0x00,  // [...,...
                /* 0010 */  0x44, 0x53, 0x00, 0x01, 0x1A, 0x7D, 0xDA, 0x54,  // DS...}.T
                /* 0018 */  0x28, 0xDC, 0x8D, 0x00, 0x01, 0x06, 0x18, 0x42,  // (......B
                /* 0020 */  0x10, 0x09, 0x10, 0x0A, 0x65, 0x82, 0x42, 0x04,  // ....e.B.
                /* 0028 */  0x92, 0x4D, 0x24, 0x31, 0x0E, 0x60, 0x30, 0x1A,  // .M$1.`0.
                /* 0030 */  0x40, 0x24, 0x07, 0x42, 0x2E, 0x98, 0x98, 0x00,  // @$.B....
                /* 0038 */  0x11, 0x10, 0xF2, 0x2A, 0xC0, 0xA6, 0x00, 0x93,  // ...*....
                /* 0040 */  0x20, 0xEA, 0xDF, 0x1F, 0xA2, 0x24, 0x38, 0x94,  //  ....$8.
                /* 0048 */  0x10, 0x08, 0x49, 0x14, 0x60, 0x5E, 0x80, 0x6E,  // ..I.`^.n
                /* 0050 */  0x01, 0x86, 0x05, 0xD8, 0x16, 0x60, 0x5A, 0x80,  // .....`Z.
                /* 0058 */  0x63, 0x48, 0x2A, 0x0D, 0x9C, 0x12, 0x58, 0x0A,  // cH*...X.
                /* 0060 */  0x84, 0x84, 0x0A, 0x50, 0x2E, 0xC0, 0xB7, 0x00,  // ...P....
                /* 0068 */  0xED, 0x88, 0x92, 0x2C, 0xC0, 0x32, 0x8C, 0x08,  // ...,.2..
                /* 0070 */  0x3C, 0x8A, 0xC8, 0x46, 0xE3, 0xD0, 0xD8, 0x61,  // <..F...a
                /* 0078 */  0x58, 0x26, 0x98, 0x06, 0x71, 0x18, 0x65, 0x23,  // X&..q.e#
                /* 0080 */  0x8B, 0xC0, 0x13, 0xEA, 0x54, 0x80, 0x5C, 0x01,  // ....T.\.
                /* 0088 */  0xC2, 0x04, 0x88, 0x47, 0x15, 0x46, 0x73, 0x50,  // ...G.FsP
                /* 0090 */  0x04, 0x3F, 0x34, 0x46, 0xCC, 0x98, 0x08, 0x6C,  // .?4F...l
                /* 0098 */  0xE7, 0xD8, 0x1A, 0xC5, 0x69, 0x14, 0x2E, 0x40,  // ....i..@
                /* 00A0 */  0x3A, 0x86, 0x46, 0x70, 0x5C, 0xE1, 0x0D, 0x76,  // :.Fp\..v
                /* 00A8 */  0x3A, 0x71, 0xCE, 0x21, 0x54, 0x94, 0xAE, 0x05,  // :q.!T...
                /* 00B0 */  0x08, 0x9A, 0x24, 0x05, 0x89, 0x66, 0xA8, 0xA2,  // ..$..f..
                /* 00B8 */  0x41, 0x05, 0x78, 0xC0, 0x1A, 0x04, 0x4A, 0x06,  // A.x...J.
                /* 00C0 */  0x84, 0x3C, 0x0B, 0xB0, 0x3E, 0x3A, 0x42, 0x60,  // .<..>:B`
                /* 00C8 */  0xF7, 0x02, 0x14, 0x0A, 0x50, 0x26, 0xC0, 0x1A,  // ....P&..
                /* 00D0 */  0x84, 0xB4, 0x09, 0xB0, 0x38, 0x15, 0xCD, 0xA8,  // ....8...
                /* 00D8 */  0x2D, 0x01, 0x0E, 0xA1, 0x04, 0x12, 0x2A, 0x4A,  // -.....*J
                /* 00E0 */  0x8C, 0x93, 0xAA, 0x51, 0x80, 0x41, 0x14, 0x81,  // ...Q.A..
                /* 00E8 */  0x44, 0xEC, 0x6C, 0x62, 0x42, 0x29, 0x0E, 0x53,  // D.lbB).S
                /* 00F0 */  0x30, 0xB1, 0xE2, 0x46, 0x89, 0x16, 0x24, 0x6C,  // 0..F..$l
                /* 00F8 */  0x90, 0x30, 0xA1, 0xDB, 0x1F, 0x04, 0x89, 0x75,  // .0.....u
                /* 0100 */  0x16, 0xD0, 0x91, 0xC0, 0x91, 0x46, 0x83, 0x1A,  // .....F..
                /* 0108 */  0x7F, 0x82, 0xE7, 0x01, 0x4F, 0xEB, 0xEC, 0x0E,  // ....O...
                /* 0110 */  0xF1, 0xB0, 0x0E, 0x2E, 0xC8, 0x39, 0x9E, 0x58,  // .....9.X
                /* 0118 */  0x9D, 0x07, 0x01, 0x32, 0x64, 0x86, 0x95, 0xE0,  // ...2d...
                /* 0120 */  0xDF, 0xC0, 0x27, 0x03, 0xFC, 0x2C, 0x03, 0xBE,  // ..'..,..
                /* 0128 */  0x12, 0x3C, 0x10, 0xB0, 0x61, 0x86, 0xC3, 0x0C,  // .<..a...
                /* 0130 */  0xD1, 0xFF, 0xFF, 0x41, 0x87, 0x3B, 0x81, 0x43,  // ...A.;.C
                /* 0138 */  0x64, 0x80, 0x9E, 0xD7, 0xB3, 0x00, 0x76, 0x54,  // d.....vT
                /* 0140 */  0x27, 0x73, 0xCA, 0xA5, 0x0A, 0x30, 0x7B, 0x09,  // 's...0{.
                /* 0148 */  0xD0, 0xC4, 0x12, 0x1C, 0x8F, 0x4F, 0x00, 0x9E,  // .....O..
                /* 0150 */  0xCF, 0x09, 0x27, 0xB0, 0xFC, 0x41, 0xA0, 0x46,  // ..'..A.F
                /* 0158 */  0x66, 0x68, 0x4F, 0xF2, 0xB4, 0x5E, 0x04, 0x7C,  // fhO..^.|
                /* 0160 */  0x3E, 0x38, 0x2C, 0x26, 0x16, 0x42, 0x0A, 0x20,  // >8,&.B. 
                /* 0168 */  0x34, 0x1E, 0xF0, 0x2B, 0x3E, 0x13, 0x08, 0xE1,  // 4..+>...
                /* 0170 */  0x6D, 0xC1, 0xF3, 0x35, 0x41, 0x79, 0xC0, 0xE8,  // m..5Ay..
                /* 0178 */  0x01, 0xD9, 0xAF, 0x00, 0x84, 0xE0, 0x2F, 0x0E,  // ....../.
                /* 0180 */  0x47, 0xF4, 0xD4, 0x10, 0x21, 0x41, 0x88, 0xB8,  // G...!A..
                /* 0188 */  0x27, 0x6F, 0xF0, 0x73, 0x79, 0x1A, 0x78, 0x53,  // 'o.sy.xS
                /* 0190 */  0x30, 0x44, 0x02, 0x8B, 0x3C, 0x38, 0xA0, 0xE1,  // 0D..<8..
                /* 0198 */  0xF9, 0x21, 0x20, 0xFA, 0xD1, 0x9C, 0x4B, 0xF0,  // .! ...K.
                /* 01A0 */  0xA3, 0x89, 0x72, 0x0A, 0x87, 0xE3, 0x23, 0x85,  // ..r...#.
                /* 01A8 */  0x11, 0xA2, 0x3F, 0x49, 0x3C, 0x59, 0x58, 0xF3,  // ..?I<YX.
                /* 01B0 */  0x04, 0x74, 0x5E, 0x38, 0xA3, 0x77, 0x01, 0x0F,  // .t^8.w..
                /* 01B8 */  0x58, 0xAF, 0x0E, 0x9D, 0x06, 0x2C, 0x6A, 0xA1,  // X....,j.
                /* 01C0 */  0xB2, 0xB1, 0x50, 0x1F, 0x08, 0xA8, 0xA4, 0x13,  // ..P.....
                /* 01C8 */  0x82, 0xC6, 0x83, 0xD3, 0x7A, 0xCF, 0x20, 0x30,  // ....z. 0
                /* 01D0 */  0x8F, 0x13, 0x5C, 0x04, 0xA0, 0x4E, 0x23, 0x3C,  // ..\..N#<
                /* 01D8 */  0x3E, 0x84, 0xC2, 0x8F, 0x88, 0x0E, 0xC0, 0x71,  // >......q
                /* 01E0 */  0xC1, 0x28, 0x88, 0x87, 0xEF, 0x28, 0x10, 0x72,  // .(...(.r
                /* 01E8 */  0x72, 0x12, 0x40, 0x0F, 0x02, 0x7F, 0xCA, 0x78,  // r.@....x
                /* 01F0 */  0x5E, 0x80, 0x85, 0x77, 0x6C, 0xA7, 0xE6, 0x69,  // ^..wl..i
                /* 01F8 */  0x18, 0xCE, 0x7F, 0x14, 0x0A, 0x47, 0xEE, 0x01,  // .....G..
                /* 0200 */  0x27, 0xFD, 0xFF, 0x4F, 0xC0, 0xCF, 0x03, 0xF0,  // '..O....
                /* 0208 */  0xEF, 0x1A, 0x1E, 0xCA, 0x29, 0x3C, 0x60, 0x3C,  // ....)<`<
                /* 0210 */  0x5E, 0x24, 0xB0, 0xC0, 0xF3, 0x00, 0x28, 0x80,  // ^$....(.
                /* 0218 */  0x7C, 0x03, 0xB0, 0xD2, 0x53, 0x00, 0x9D, 0x43,  // |...S..C
                /* 0220 */  0x88, 0x30, 0xD1, 0x0C, 0x8F, 0x09, 0x0E, 0x21,  // .0.....!
                /* 0228 */  0x0B, 0x10, 0x92, 0x35, 0x2E, 0xD4, 0xA1, 0xC0,  // ...5....
                /* 0230 */  0x27, 0x16, 0x76, 0x22, 0xC1, 0x0D, 0xEA, 0xD5,  // '.v"....
                /* 0238 */  0xC1, 0xC3, 0x36, 0xAC, 0x47, 0xCA, 0x61, 0x8D,  // ..6.G.a.
                /* 0240 */  0x16, 0xF6, 0x80, 0x1F, 0x1B, 0x7C, 0xE5, 0xF0,  // .....|..
                /* 0248 */  0xCC, 0x7C, 0x4A, 0xF1, 0x61, 0x03, 0x2C, 0x80,  // .|J.a.,.
                /* 0250 */  0x78, 0xEF, 0xF7, 0x0C, 0x32, 0x01, 0x03, 0xB2,  // x...2...
                /* 0258 */  0x23, 0x0C, 0x78, 0x3C, 0x4E, 0x8D, 0xCC, 0xE1,  // #.x<N...
                /* 0260 */  0x69, 0x01, 0x87, 0xF3, 0x66, 0x80, 0x3F, 0xE3,  // i...f.?.
                /* 0268 */  0xE8, 0xE8, 0x80, 0xE2, 0xB0, 0xAC, 0xA3, 0x03,  // ........
                /* 0270 */  0x7A, 0xEA, 0x6F, 0x1F, 0x07, 0x16, 0xF8, 0x1C,  // z.o.....
                /* 0278 */  0x63, 0x3C, 0x6C, 0xBC, 0xE8, 0x30, 0x19, 0x67,  // c<l..0.g
                /* 0280 */  0x07, 0x14, 0x85, 0x0F, 0x0F, 0x3E, 0x3B, 0xF0,  // .....>;.
                /* 0288 */  0xC0, 0x60, 0x14, 0xC4, 0x67, 0x07, 0x87, 0x39,  // .`..g..9
                /* 0290 */  0x3B, 0xA0, 0x4F, 0x42, 0x1E, 0x05, 0x9F, 0x04,  // ;.OB....
                /* 0298 */  0xE6, 0xF0, 0x80, 0xF9, 0xFF, 0x1F, 0x1E, 0x00,  // ........
                /* 02A0 */  0x5F, 0xD1, 0x0F, 0x0F, 0xA0, 0x1B, 0xB5, 0x0F,  // _.......
                /* 02A8 */  0x0F, 0xC0, 0x75, 0x74, 0x0F, 0x0F, 0xE0, 0xBE,  // ..ut....
                /* 02B0 */  0x2F, 0xC0, 0x19, 0x82, 0x4E, 0x0F, 0xA8, 0x51,  // /...N..Q
                /* 02B8 */  0x58, 0xCE, 0xE9, 0x01, 0x3D, 0xDB, 0x83, 0x35,  // X...=..5
                /* 02C0 */  0x2C, 0x93, 0x70, 0x76, 0x40, 0x9D, 0x62, 0x3C,  // ,.pv@.b<
                /* 02C8 */  0x78, 0x9F, 0x1D, 0x78, 0x58, 0x30, 0x0A, 0xE2,  // x..xX0..
                /* 02D0 */  0x61, 0x3B, 0x08, 0x84, 0xFE, 0xFF, 0x67, 0x07,  // a;....g.
                /* 02D8 */  0xDC, 0x20, 0x3D, 0x06, 0xDC, 0xC9, 0x01, 0xF0,  // . =.....
                /* 02E0 */  0x16, 0xFA, 0xE4, 0x00, 0x3A, 0x48, 0x9F, 0x1C,  // ....:H..
                /* 02E8 */  0x80, 0xEB, 0x79, 0x0A, 0x7F, 0x72, 0x00, 0xDB,  // ..y..r..
                /* 02F0 */  0xC5, 0x00, 0xF5, 0x68, 0x21, 0x63, 0x60, 0x91,  // ...h!c`.
                /* 02F8 */  0x4F, 0x04, 0xA8, 0x13, 0x14, 0x1F, 0xA6, 0x8F,  // O.......
                /* 0300 */  0x71, 0x4F, 0x01, 0xB0, 0xFF, 0xFF, 0xD3, 0xF7,  // qO......
                /* 0308 */  0x65, 0x8F, 0x1D, 0x01, 0x1E, 0xCE, 0x3C, 0x55,  // e.....<U
                /* 0310 */  0x1F, 0xBC, 0x80, 0xCB, 0xA1, 0x03, 0x77, 0x76,  // ......wv
                /* 0318 */  0xF0, 0x10, 0xF8, 0x00, 0x5A, 0xBD, 0x31, 0x90,  // ....Z.1.
                /* 0320 */  0xF3, 0xC1, 0x29, 0xE1, 0x0E, 0x0A, 0x0C, 0xEB,  // ..).....
                /* 0328 */  0x15, 0xF1, 0x4D, 0x8E, 0x9F, 0x7F, 0x3C, 0xED,  // ..M...<.
                /* 0330 */  0xE3, 0xC2, 0x0E, 0x82, 0xCB, 0x7F, 0xF9, 0xF9,  // ........
                /* 0338 */  0x5C, 0x49, 0x05, 0xC3, 0xA0, 0x8E, 0x96, 0x80,  // \I......
                /* 0340 */  0xED, 0x71, 0x63, 0x8F, 0x96, 0xB0, 0x8D, 0xE1,  // .qc.....
                /* 0348 */  0xEA, 0x2C, 0xF2, 0x2E, 0x70, 0x3E, 0x87, 0x12,  // .,..p>..
                /* 0350 */  0xC3, 0x57, 0xCA, 0xFF, 0x7F, 0x9C, 0xE7, 0xC9,  // .W......
                /* 0358 */  0x53, 0x8A, 0xF5, 0x68, 0x69, 0x98, 0x10, 0xCF,  // S..hi...
                /* 0360 */  0x94, 0x8F, 0x96, 0x3E, 0x15, 0x3C, 0x3E, 0xF4,  // ...>.<>.
                /* 0368 */  0x86, 0x22, 0xB8, 0xC8, 0x51, 0x0D, 0xF4, 0x64,  // ."..Q..d
                /* 0370 */  0x12, 0x2D, 0x5E, 0xD0, 0x70, 0x81, 0x7C, 0xB4,  // .-^.p.|.
                /* 0378 */  0x64, 0xD1, 0x5F, 0x30, 0x3A, 0x0B, 0xF8, 0x68,  // d._0:..h
                /* 0380 */  0x09, 0xF0, 0xE3, 0xAC, 0xE8, 0xA3, 0x10, 0x1E,  // ........
                /* 0388 */  0xF5, 0x9D, 0x12, 0x73, 0xB8, 0xE1, 0xA2, 0x0E,  // ...s....
                /* 0390 */  0x37, 0xA8, 0xD3, 0x84, 0x0F, 0x12, 0x0C, 0x94,  // 7.......
                /* 0398 */  0x1F, 0xF8, 0x30, 0x07, 0x1A, 0xE0, 0xF2, 0xFF,  // ..0.....
                /* 03A0 */  0x3F, 0xD0, 0x80, 0xFB, 0xA0, 0x04, 0xBE, 0x33,  // ?......3
                /* 03A8 */  0x0D, 0x38, 0x06, 0x10, 0xF8, 0x91, 0xE1, 0x99,  // .8......
                /* 03B0 */  0x06, 0x58, 0x5D, 0xAB, 0x7C, 0xA6, 0x01, 0xD7,  // .X].|...
                /* 03B8 */  0x81, 0x80, 0x9D, 0x67, 0x60, 0x89, 0x7B, 0x06,  // ...g`.{.
                /* 03C0 */  0x98, 0x40, 0xE2, 0x1F, 0x05, 0x92, 0xF3, 0x3A,  // .@.....:
                /* 03C8 */  0xA0, 0x30, 0x3E, 0xCF, 0x00, 0xAE, 0x80, 0x12,  // .0>.....
                /* 03D0 */  0xFC, 0xFF, 0x9F, 0x67, 0xC0, 0x7E, 0x56, 0x88,  // ...g.~V.
                /* 03D8 */  0xEC, 0x93, 0x83, 0xEF, 0xDE, 0xD8, 0xC3, 0x37,  // .......7
                /* 03E0 */  0x18, 0x0E, 0x32, 0x9E, 0x51, 0x90, 0xE7, 0x86,  // ..2.Q...
                /* 03E8 */  0x57, 0x6F, 0x5F, 0x65, 0xE2, 0x9C, 0xCF, 0x73,  // Wo_e...s
                /* 03F0 */  0x8D, 0x8F, 0x34, 0x46, 0x79, 0x04, 0x7F, 0xFD,  // ..4Fy...
                /* 03F8 */  0x36, 0xE4, 0x7B, 0x8D, 0x61, 0xA2, 0x3C, 0x15,  // 6.{.a.<.
                /* 0400 */  0x04, 0x09, 0x1A, 0x2D, 0xC8, 0xDB, 0xB7, 0xEF,  // ...-....
                /* 0408 */  0x37, 0x46, 0x78, 0xC6, 0xF1, 0x91, 0x86, 0x45,  // 7Fx....E
                /* 0410 */  0x3A, 0x7C, 0x03, 0x34, 0x39, 0x39, 0xE0, 0x07,  // :|.499..
                /* 0418 */  0xE4, 0xFF, 0xFF, 0x81, 0x04, 0xD6, 0x31, 0x81,  // ......1.
                /* 0420 */  0x9F, 0x47, 0x80, 0x89, 0x08, 0x13, 0x27, 0x03,  // .G....'.
                /* 0428 */  0x26, 0xEC, 0x8C, 0x89, 0x16, 0x77, 0x3E, 0xD0,  // &....w>.
                /* 0430 */  0x51, 0x86, 0x4D, 0x21, 0xF0, 0x09, 0x9C, 0xC3,  // Q.M!....
                /* 0438 */  0x09, 0x3C, 0xDC, 0xBC, 0x69, 0x30, 0x41, 0x67,  // .<..i0Ag
                /* 0440 */  0x4C, 0x94, 0x14, 0x0A, 0x09, 0x81, 0xD0, 0x19,  // L.......
                /* 0448 */  0x93, 0x1F, 0x33, 0x0D, 0x66, 0x10, 0x8F, 0xDD,  // ..3.f...
                /* 0450 */  0xB1, 0x20, 0x64, 0x64, 0x18, 0xF4, 0x18, 0xC0,  // . dd....
                /* 0458 */  0x4F, 0x0F, 0x07, 0x74, 0x46, 0x11, 0x9E, 0x3E,  // O..tF..>
                /* 0460 */  0x78, 0x88, 0x83, 0xA7, 0x0F, 0x99, 0xA0, 0x1B,  // x.......
                /* 0468 */  0xE9, 0x79, 0x3E, 0x14, 0x78, 0x2D, 0x3E, 0x6B,  // .y>.x->k
                /* 0470 */  0xC2, 0x3D, 0x40, 0xFA, 0xCC, 0x03, 0x8E, 0x13,  // .=@.....
                /* 0478 */  0x8F, 0x8F, 0x9A, 0xC0, 0xE3, 0xB4, 0xE8, 0xF3,  // ........
                /* 0480 */  0x37, 0xF8, 0xFF, 0xFF, 0x47, 0x4D, 0xE0, 0x76,  // 7...GM.v
                /* 0488 */  0x18, 0xC2, 0x1D, 0xA5, 0xC0, 0x72, 0x61, 0x30,  // .....ra0
                /* 0490 */  0xC8, 0x13, 0x03, 0x4E, 0xE8, 0xE1, 0x01, 0x75,  // ...N...u
                /* 0498 */  0xF0, 0xB2, 0xC8, 0xC3, 0x03, 0x7A, 0xDE, 0x47,  // .....z.G
                /* 04A0 */  0xC7, 0x30, 0xDE, 0x80, 0x8C, 0x8E, 0x3B, 0x40,  // .0....;@
                /* 04A8 */  0x00, 0x0C, 0x19, 0xAF, 0xFF, 0xFF, 0x67, 0x70,  // ......gp
                /* 04B0 */  0xC0, 0xE6, 0x01, 0x82, 0x9D, 0x1A, 0xB0, 0x87,  // ........
                /* 04B8 */  0x08, 0xAC, 0xC0, 0x43, 0x04, 0x8A, 0xC3, 0x02,  // ...C....
                /* 04C0 */  0x0F, 0x11, 0x68, 0x18, 0xE3, 0x3E, 0x42, 0x00,  // ..h..>B.
                /* 04C8 */  0xA6, 0xFF, 0xFF, 0x47, 0x08, 0xE0, 0x10, 0xFB,  // ...G....
                /* 04D0 */  0x30, 0x0E, 0xE8, 0x99, 0xE3, 0x23, 0x04, 0x58,  // 0....#.X
                /* 04D8 */  0xCF, 0x0C, 0xEC, 0x00, 0x01, 0x9E, 0xD9, 0x3F,  // .......?
                /* 04E0 */  0x20, 0x78, 0x7A, 0x06, 0x7D, 0x7F, 0x8B, 0xE3,  //  xz.}...
                /* 04E8 */  0x9B, 0x39, 0x3D, 0x40, 0x00, 0x72, 0xFE, 0xFF,  // .9=@.r..
                /* 04F0 */  0x07, 0x08, 0xC0, 0xD9, 0x78, 0x7D, 0x80, 0x00,  // ....x}..
                /* 04F8 */  0xDC, 0x5C, 0x19, 0xB0, 0x40, 0xEC, 0xCC, 0xC0,  // .\..@...
                /* 0500 */  0x15, 0xDA, 0xF4, 0xA9, 0xD1, 0xA8, 0x55, 0x83,  // ......U.
                /* 0508 */  0x32, 0x35, 0xCA, 0x34, 0xA8, 0xD5, 0xA7, 0x52,  // 25.4...R
                /* 0510 */  0x63, 0xC6, 0xAC, 0x8C, 0xDF, 0xCF, 0x05, 0x0D,  // c.......
                /* 0518 */  0xD7, 0x31, 0x40, 0x68, 0x6C, 0x0A, 0x19, 0x19,  // .1@hl...
                /* 0520 */  0x8D, 0x97, 0xAA, 0x83, 0x25, 0x79, 0xC5, 0x0A,  // ....%y..
                /* 0528 */  0xC8, 0xE2, 0x40, 0x04, 0x64, 0x81, 0x6B, 0x12,  // ..@.d.k.
                /* 0530 */  0x90, 0xE5, 0x82, 0x08, 0xC8, 0xE1, 0x56, 0x27,  // ......V'
                /* 0538 */  0x10, 0x4B, 0xB3, 0x01, 0xC2, 0xE4, 0xE9, 0x00,  // .K......
                /* 0540 */  0xA5, 0x94, 0x02, 0x71, 0x3C, 0x10, 0x2A, 0xEB,  // ...q<.*.
                /* 0548 */  0x45, 0x2D, 0x70, 0x8B, 0x04, 0x11, 0x90, 0x65,  // E-p....e
                /* 0550 */  0xAF, 0x47, 0xFF, 0x7F, 0x20, 0x87, 0x00, 0x11,  // .G.. ...
                /* 0558 */  0x90, 0xA3, 0x79, 0x01, 0x62, 0x41, 0x41, 0x04,  // ..y.bAA.
                /* 0560 */  0xE4, 0xE8, 0x66, 0x80, 0x98, 0x10, 0x35, 0x40,  // ..f...5@
                /* 0568 */  0xEC, 0xFF, 0x0F                                 // ...
            })
            Method (_WED, 1, NotSerialized)  // _Wxx: Wake Event, xx=0x00-0xFF
            {
                If ((Arg0 == 0xB0))
                {
                    Return (One)
                }

                Return (Zero)
            }

            Method (WMMK, 3, Serialized)
            {
                Switch (ToInteger (Arg1))
                {
                    Case (One)
                    {
                        Return (One)
                    }
                    Case (0x02)
                    {
                        Return (Zero)
                    }
                    Case (0x03)
                    {
                        Return (Zero)
                    }
                    Default
                    {
                        Return (Zero)
                    }

                }
            }
        }
    }

    Name (WCDS, Package (0x61)
    {
        0x04, 
        0x04, 
        0x04, 
        Zero, 
        0x04, 
        0x04, 
        Zero, 
        Zero, 
        0x04, 
        0x04, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        0x08, 
        Zero, 
        Zero, 
        0x04, 
        0x04, 
        0x04, 
        Zero, 
        0x04, 
        0x80, 
        0x04, 
        0x04, 
        0x04, 
        Zero, 
        0x04, 
        0x04, 
        0x04, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        0x04, 
        Zero, 
        Zero, 
        0x04, 
        0x80, 
        0x04, 
        0x04, 
        0x04, 
        0x04, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        0x04, 
        Zero, 
        0x80, 
        0x80, 
        0x04, 
        Zero, 
        Zero, 
        0x04, 
        Zero, 
        Zero, 
        0x04, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        0x80, 
        0x04, 
        0x04, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        0x04, 
        0x0400, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        0x80, 
        Zero, 
        Zero, 
        Zero, 
        0x80, 
        Zero, 
        Zero, 
        Zero, 
        Zero, 
        0x04
    })
    Name (ZOBF, Buffer (0x0128){})
    Name (GMBF, Buffer (0x1000){})
    Method (HWMC, 2, NotSerialized)
    {
        CreateDWordField (Arg1, Zero, SGIN)
        CreateDWordField (Arg1, 0x04, COMD)
        CreateDWordField (Arg1, 0x08, CMDT)
        CreateDWordField (Arg1, 0x0C, DSZI)
        Local5 = DSZI /* \HWMC.DSZI */
        If ((Local5 >= One))
        {
            CreateField (Arg1, 0x80, (Local5 * 0x08), DAIN)
            CreateByteField (Arg1, 0x10, D008)
        }

        If ((Local5 >= 0x02))
        {
            CreateByteField (Arg1, 0x11, D009)
        }

        If ((Local5 >= 0x03))
        {
            CreateByteField (Arg1, 0x12, D010)
        }

        If ((Local5 >= 0x04))
        {
            CreateDWordField (Arg1, 0x10, D032)
        }

        If ((Local5 >= 0x80))
        {
            CreateField (Arg1, 0x80, 0x0400, D128)
        }

        If ((Arg0 == One))
        {
            Local0 = Zero
        }

        If ((Arg0 == 0x02))
        {
            Local0 = 0x04
        }

        If ((Arg0 == 0x03))
        {
            Local0 = 0x80
        }

        If ((Arg0 == 0x04))
        {
            Local0 = 0x0400
        }

        If ((Arg0 == 0x05))
        {
            Local0 = 0x1000
        }

        Local1 = Buffer ((0x08 + Local0)){}
        CreateDWordField (Local1, Zero, SIOU)
        CreateDWordField (Local1, 0x04, RETC)
        If ((Local5 > 0x80))
        {
            Local7 = Zero
            If (((COMD == 0x00020002) & (CMDT == 0x06)))
            {
                Local7 = One
            }

            If ((CMDT == 0x53))
            {
                Local7 = One
            }

            If ((Local7 == One))
            {
                WBUF = DAIN /* \HWMC.DAIN */
            }
            Else
            {
                GMBF = DAIN /* \HWMC.DAIN */
            }
        }
        ElseIf ((Local5 >= One))
        {
            WBUF = DAIN /* \HWMC.DAIN */
        }

        SIOU = 0x4C494146
        RETC = 0x02
        If ((SGIN == 0x55434553))
        {
            RETC = 0x03
            If ((COMD == One))
            {
                RETC = 0x04
                If ((CMDT == One))
                {
                    Local2 = \_SB.WMID.GDST ()
                    RETC = Zero
                }

                If ((CMDT == 0x04))
                {
                    Local2 = \_SB.WMID.GDKS ()
                    RETC = Zero
                }

                If ((CMDT == 0x05))
                {
                    Local2 = \_SB.WMID.GWLS ()
                    RETC = Zero
                }

                If ((CMDT == 0x07))
                {
                    If (DSZI)
                    {
                        Local3 = DerefOf (Arg1 [0x10])
                        Local2 = \_SB.WMID.GBIF (Local3)
                        RETC = Zero
                    }
                    Else
                    {
                        RETC = 0x05
                    }
                }

                If ((CMDT == 0x08))
                {
                    Local2 = \_SB.WMID.GBBT ()
                    RETC = Zero
                }

                If ((CMDT == 0x09))
                {
                    Local2 = \_SB.WMID.GHKS ()
                    RETC = Zero
                }

                If ((CMDT == 0x0A))
                {
                    Local2 = \_SB.WMID.GHKF ()
                    RETC = Zero
                }

                If ((CMDT == 0x0C))
                {
                    Local2 = \_SB.WMID.GBBV ()
                    RETC = Zero
                }

                If ((CMDT == 0x0D))
                {
                    Local2 = \_SB.WMID.GFRC ()
                    RETC = Zero
                }

                If ((CMDT == 0x0F))
                {
                    Local2 = \_SB.WMID.GSAS ()
                    RETC = Zero
                }

                If ((CMDT == 0x10))
                {
                    Local2 = \_SB.WMID.GWSD ()
                    RETC = Zero
                }

                If ((CMDT == 0x1B))
                {
                    If ((OSVR >= 0x0F))
                    {
                        RETC = 0x04
                    }
                    Else
                    {
                        Local2 = \_SB.WMID.GWDI ()
                        RETC = Zero
                    }
                }

                If ((CMDT == 0x1D))
                {
                    Local2 = \_SB.WMID.GSDC ()
                    RETC = Zero
                }

                If ((CMDT == 0x1E))
                {
                    Local2 = \_SB.WMID.GBUS ()
                    RETC = Zero
                }

                If ((CMDT == 0x29))
                {
                    Local2 = \_SB.WMID.GFCS ()
                    RETC = Zero
                }

                If ((CMDT == 0x2B))
                {
                    Local2 = \_SB.WMID.GBCO ()
                    RETC = Zero
                }

                If ((CMDT == 0x2A))
                {
                    Local2 = \_SB.WMID.GPES ()
                    RETC = Zero
                }

                If ((CMDT == 0x28))
                {
                    If ((DSZI == 0x04))
                    {
                        If ((((((D032 >= Zero) && (D032 <= 
                            0xAA)) || ((D032 >= 0x10) && (D032 <= 0x15))) || ((
                            D032 >= 0x20) && (D032 <= 0x25))) || (D032 == 0xAA)))
                        {
                            Local2 = \_SB.WMID.GTDC (D008)
                            RETC = Zero
                        }
                        Else
                        {
                            RETC = 0x06
                        }
                    }
                    Else
                    {
                        RETC = 0x05
                    }
                }

                If ((CMDT == 0x2C))
                {
                    Local2 = \_SB.WMID.GTCS ()
                    RETC = Zero
                }

                If ((CMDT == 0x31))
                {
                    Local2 = \_SB.WMID.GPSS ()
                    RETC = Zero
                }

                If ((CMDT == 0x34))
                {
                    Local2 = \_SB.WMID.GBKT ()
                    RETC = Zero
                }

                If ((CMDT == 0x35))
                {
                    Local2 = \_SB.WMID.GJGD ()
                    RETC = Zero
                }

                If ((CMDT == 0x36))
                {
                    Local2 = \_SB.WMID.GPST ()
                    RETC = Zero
                }

                If ((CMDT == 0x37))
                {
                    Local2 = \_SB.WMID.GBCT ()
                    RETC = Zero
                }

                If ((CMDT == 0x38))
                {
                    Local2 = \_SB.WMID.GBST ()
                    RETC = Zero
                }

                If ((CMDT == 0x3E))
                {
                    Local2 = \_SB.WMID.GPPS ()
                    RETC = Zero
                }

                If ((YRCL >= 0x0181))
                {
                    If ((CMDT == 0x44))
                    {
                        Local2 = \_SB.WMID.GBMF ()
                        RETC = Zero
                    }
                }

                If ((CMDT == 0x4B))
                {
                    Local2 = \_SB.WMID.RHPM ()
                    RETC = Zero
                }

                If ((CMDT == 0x52))
                {
                    Local2 = \_SB.WMID.GDSS ()
                    RETC = Zero
                }

                If ((CMDT == 0x56))
                {
                    Local2 = \_SB.WMID.GABD ()
                    RETC = Zero
                }

                If ((CMDT == 0x58))
                {
                    Local2 = \_SB.WMID.RBCT ()
                    RETC = Zero
                }

                If ((CMDT == 0x5A))
                {
                    Local2 = \_SB.WMID.GSCM ()
                    RETC = Zero
                }

                If ((CMDT == 0x5C))
                {
                    Local2 = \_SB.WMID.GDDS ()
                    RETC = Zero
                }

                If ((CMDT == 0x61))
                {
                    Local2 = \_SB.WMID.GMLS ()
                    RETC = Zero
                }
            }

            If ((COMD == 0x02))
            {
                RETC = 0x04
                If (((CMDT > Zero) && (CMDT <= 0x61)))
                {
                    If ((DSZI < DerefOf (WCDS [(CMDT - One)])))
                    {
                        RETC = 0x05
                    }
                    Else
                    {
                        CreateDWordField (Arg1, 0x10, DDWD)
                        If ((CMDT == One))
                        {
                            Local2 = \_SB.WMID.SDST (DDWD)
                            RETC = Zero
                        }

                        If ((CMDT == 0x05))
                        {
                            Local2 = \_SB.WMID.SWLS (DDWD)
                            RETC = Zero
                        }

                        If ((CMDT == 0x09))
                        {
                            Local2 = \_SB.WMID.SHKS (DDWD)
                            RETC = Zero
                        }

                        If ((CMDT == 0x0A))
                        {
                            Local2 = \_SB.WMID.SHKF (DDWD)
                            RETC = Zero
                        }

                        If ((CMDT == 0x10))
                        {
                            If ((DSZI != DerefOf (WCDS [(CMDT - One)])))
                            {
                                RETC = 0x05
                            }
                            Else
                            {
                                CreateField (Arg1, 0x80, 0x40, DB08)
                                Local2 = \_SB.WMID.SWSD (DB08)
                                RETC = Zero
                            }
                        }

                        If ((CMDT == 0x1B))
                        {
                            If ((OSVR >= 0x0F))
                            {
                                RETC = 0x04
                            }
                            Else
                            {
                                CreateByteField (Arg1, 0x10, SWD0)
                                CreateByteField (Arg1, 0x11, SWD1)
                                CreateByteField (Arg1, 0x12, SWD2)
                                CreateByteField (Arg1, 0x13, SWD3)
                                Local2 = \_SB.WMID.SWDS (SWD0, SWD1, SWD2, SWD3)
                                RETC = Zero
                            }
                        }

                        If ((CMDT == 0x1D))
                        {
                            If ((DSZI != DerefOf (WCDS [(CMDT - One)])))
                            {
                                RETC = 0x05
                            }
                            Else
                            {
                                CreateByteField (Arg1, 0x10, SDC0)
                                CreateByteField (Arg1, 0x11, SDC1)
                                CreateByteField (Arg1, 0x12, SDC2)
                                CreateByteField (Arg1, 0x13, SDC3)
                                Local2 = \_SB.WMID.SSDC (SDC0, SDC1, SDC2, SDC3)
                                RETC = Zero
                            }
                        }

                        If ((CMDT == 0x1E))
                        {
                            Local2 = \_SB.WMID.SBUS (DDWD)
                            RETC = Zero
                        }

                        If ((CMDT == 0x29))
                        {
                            Local2 = \_SB.WMID.SFCS (DDWD)
                            RETC = Zero
                        }

                        If ((CMDT == 0x2B))
                        {
                            If ((DSZI != DerefOf (WCDS [(CMDT - One)])))
                            {
                                RETC = 0x05
                            }
                            Else
                            {
                                CreateByteField (Arg1, 0x10, BCO0)
                                CreateByteField (Arg1, 0x11, BCO1)
                                CreateByteField (Arg1, 0x12, BCO2)
                                CreateByteField (Arg1, 0x13, BCO3)
                                Local2 = \_SB.WMID.SBCO (BCO0, BCO1, BCO2, BCO3)
                                RETC = Zero
                            }
                        }

                        If ((CMDT == 0x2A))
                        {
                            Local2 = \_SB.WMID.SPES (DDWD)
                            RETC = Zero
                        }

                        If ((CMDT == 0x28))
                        {
                            If ((DSZI == 0x80))
                            {
                                If (((((D008 >= 0x10) && (D008 <= 0x15)) || 
                                    ((D008 >= 0x20) && (D008 <= 0x30))) || (D008 == 0xAA)))
                                {
                                    If ((D008 != 0xAA))
                                    {
                                        If (((D009 != One) && (D009 != 0x02)))
                                        {
                                            RETC = 0x06
                                        }
                                        Else
                                        {
                                            Local2 = \_SB.WMID.STDC (D008, D009, D010)
                                            RETC = Zero
                                        }
                                    }
                                    Else
                                    {
                                        Local2 = \_SB.WMID.STDC (D008, D009, D010)
                                        RETC = Zero
                                    }
                                }
                                Else
                                {
                                    RETC = 0x06
                                }
                            }
                            Else
                            {
                                RETC = 0x05
                            }
                        }

                        If ((CMDT == 0x2C))
                        {
                            If ((DSZI != DerefOf (WCDS [(CMDT - One)])))
                            {
                                RETC = 0x05
                            }
                            Else
                            {
                                CreateByteField (Arg1, 0x10, STC0)
                                CreateByteField (Arg1, 0x11, STC1)
                                CreateByteField (Arg1, 0x12, STC2)
                                CreateByteField (Arg1, 0x13, STC3)
                                Local2 = \_SB.WMID.STCS (STC0, STC1, STC2, STC3)
                                RETC = Zero
                            }
                        }

                        If ((CMDT == 0x31))
                        {
                            If ((DSZI != DerefOf (WCDS [(CMDT - One)])))
                            {
                                RETC = 0x05
                            }
                            Else
                            {
                                CMSW (0xCE, D008)
                                CMSW (0xCF, D009)
                                Local2 = \_SB.WMID.SPSS (D008, D009)
                                RETC = Zero
                            }
                        }

                        If ((CMDT == 0x34))
                        {
                            Local2 = \_SB.WMID.SBKT (DDWD)
                            RETC = Zero
                        }

                        If ((CMDT == 0x35))
                        {
                            CreateByteField (Arg1, 0x10, JGD0)
                            CreateByteField (Arg1, 0x11, JGD1)
                            CreateByteField (Arg1, 0x12, JGD2)
                            CreateByteField (Arg1, 0x13, JGD3)
                            Local2 = \_SB.WMID.SJGD (JGD0, JGD1, JGD2, JGD3)
                            RETC = Zero
                        }

                        If ((CMDT == 0x36))
                        {
                            Local2 = \_SB.WMID.SPST (D128)
                            RETC = Zero
                        }

                        If ((CMDT == 0x37))
                        {
                            Local2 = \_SB.WMID.SBCT (D128)
                            RETC = Zero
                        }

                        If ((CMDT == 0x38))
                        {
                            CreateByteField (Arg1, 0x10, BST0)
                            CreateByteField (Arg1, 0x11, BST1)
                            CreateByteField (Arg1, 0x12, BST2)
                            CreateByteField (Arg1, 0x13, BST3)
                            Local2 = \_SB.WMID.SBST (BST0, BST1, BST2, BST3)
                            RETC = Zero
                        }

                        If ((CMDT == 0x4B))
                        {
                            Local2 = \_SB.WMID.WHPM (D128)
                            RETC = Zero
                        }

                        If ((CMDT == 0x4D))
                        {
                            CreateByteField (Arg1, 0x10, PPS4)
                            CreateByteField (Arg1, 0x11, PPS5)
                            CreateByteField (Arg1, 0x12, PPS6)
                            CreateByteField (Arg1, 0x13, PPS7)
                            Local2 = \_SB.WMID.SPCS (PPS4, PPS5, PPS6, PPS7)
                            RETC = Zero
                        }

                        If ((CMDT == 0x52))
                        {
                            Local2 = \_SB.WMID.SDSS ()
                            RETC = Zero
                        }

                        If ((CMDT == 0x58))
                        {
                            Local2 = \_SB.WMID.WBCT (D128)
                            RETC = Zero
                        }

                        If ((CMDT == 0x5A))
                        {
                            Local2 = \_SB.WMID.SSCM ()
                            RETC = Zero
                        }

                        If ((CMDT == 0x5C))
                        {
                            Local2 = \_SB.WMID.SOPC (D128)
                            RETC = Zero
                        }

                        If ((CMDT == 0x61))
                        {
                            Local2 = \_SB.WMID.SMLS (DDWD)
                            RETC = Zero
                        }
                    }
                }
            }

            If ((COMD == 0x00020002))
            {
                If ((CMDT == One))
                {
                    Local2 = \_SB.WMID.CSTA ()
                    RETC = Zero
                }

                If ((CMDT == 0x02))
                {
                    Local2 = \_SB.WMID.CACT ()
                    RETC = Zero
                }

                If ((CMDT == 0x03))
                {
                    Local2 = \_SB.WMID.CDAC ()
                    RETC = Zero
                }

                If ((CMDT == 0x06))
                {
                    Local2 = \_SB.WMID.CAIP ()
                    RETC = Zero
                }
            }

            If ((COMD == 0x00020008))
            {
                If ((CMDT == One))
                {
                    Local2 = \_SB.WMID.GM01 ()
                    RETC = Zero
                }

                If ((CMDT == 0x02))
                {
                    Local2 = \_SB.WMID.GM02 ()
                    RETC = Zero
                }

                If ((CMDT == 0x03))
                {
                    Local2 = \_SB.WMID.GM03 ()
                    RETC = Zero
                }

                If ((CMDT == 0x04))
                {
                    Local2 = \_SB.WMID.GM04 ()
                    RETC = Zero
                }

                If ((CMDT == 0x05))
                {
                    Local2 = \_SB.WMID.GM05 ()
                    RETC = Zero
                }

                If ((CMDT == 0x06))
                {
                    Local2 = \_SB.WMID.GM06 ()
                    RETC = Zero
                }

                If ((CMDT == 0x07))
                {
                    Local2 = \_SB.WMID.GM07 ()
                    RETC = Zero
                }

                If ((CMDT == 0x08))
                {
                    Local2 = \_SB.WMID.GM08 ()
                    RETC = Zero
                }

                If ((CMDT == 0x09))
                {
                    Local2 = \_SB.WMID.GM09 ()
                    RETC = Zero
                }

                If ((CMDT == 0x0A))
                {
                    Local2 = \_SB.WMID.GM0A ()
                    RETC = Zero
                }

                If ((CMDT == 0x0B))
                {
                    Local2 = \_SB.WMID.GM0B ()
                    RETC = Zero
                }

                If ((CMDT == 0x0C))
                {
                    Local2 = \_SB.WMID.GM0C ()
                    RETC = Zero
                }

                If ((CMDT == 0x0D))
                {
                    Local2 = \_SB.WMID.GM0D ()
                    RETC = Zero
                }

                If ((CMDT == 0x0E))
                {
                    Local2 = \_SB.WMID.GM0E ()
                    RETC = Zero
                }

                If ((CMDT == 0x0F))
                {
                    Local2 = \_SB.WMID.GM0F ()
                    RETC = Zero
                }

                If ((CMDT == 0x10))
                {
                    Local2 = \_SB.WMID.GM10 ()
                    RETC = Zero
                }

                If ((CMDT == 0x11))
                {
                    Local2 = \_SB.WMID.GM11 ()
                    RETC = Zero
                }

                If ((CMDT == 0x12))
                {
                    Local2 = \_SB.WMID.GM12 ()
                    RETC = Zero
                }

                If ((CMDT == 0x13))
                {
                    Local2 = \_SB.WMID.GM13 ()
                    RETC = Zero
                }

                If ((CMDT == 0x14))
                {
                    Local2 = \_SB.WMID.GM14 ()
                    RETC = Zero
                }

                If ((CMDT == 0x15))
                {
                    Local2 = \_SB.WMID.GM15 ()
                    RETC = Zero
                }

                If ((CMDT == 0x16))
                {
                    Local2 = \_SB.WMID.GM16 ()
                    RETC = Zero
                }

                If ((CMDT == 0x17))
                {
                    Local2 = \_SB.WMID.GM17 ()
                    RETC = Zero
                }

                If ((CMDT == 0x18))
                {
                    Local2 = \_SB.WMID.GM18 ()
                    RETC = Zero
                }

                If ((CMDT == 0x19))
                {
                    Local2 = \_SB.WMID.GM19 ()
                    RETC = Zero
                }

                If ((CMDT == 0x1A))
                {
                    Local2 = \_SB.WMID.GM1A ()
                    RETC = Zero
                }

                If ((CMDT == 0x1B))
                {
                    Local2 = \_SB.WMID.GM1B ()
                    RETC = Zero
                }

                If ((CMDT == 0x1C))
                {
                    Local2 = \_SB.WMID.GM1C ()
                    RETC = Zero
                }

                If ((CMDT == 0x1D))
                {
                    Local2 = \_SB.WMID.GM1D ()
                    RETC = Zero
                }

                If ((CMDT == 0x1E))
                {
                    Local2 = \_SB.WMID.GM1E ()
                    RETC = Zero
                }

                If ((CMDT == 0x1F))
                {
                    Local2 = \_SB.WMID.GM1F ()
                    RETC = Zero
                }

                If ((CMDT == 0x20))
                {
                    Local2 = \_SB.WMID.GM20 ()
                    RETC = Zero
                }

                If ((CMDT == 0x21))
                {
                    Local2 = \_SB.WMID.GM21 ()
                    RETC = Zero
                }

                If ((CMDT == 0x22))
                {
                    Local2 = \_SB.WMID.GM22 ()
                    RETC = Zero
                }

                If ((CMDT == 0x23))
                {
                    Local2 = \_SB.WMID.GM23 ()
                    RETC = Zero
                }

                If ((CMDT == 0x24))
                {
                    Local2 = \_SB.WMID.GM24 ()
                    RETC = Zero
                }

                If ((CMDT == 0x25))
                {
                    Local2 = \_SB.WMID.GM25 ()
                    RETC = Zero
                }

                If ((CMDT == 0x26))
                {
                    Local2 = \_SB.WMID.GM26 ()
                    RETC = Zero
                }

                If ((CMDT == 0x27))
                {
                    Local2 = \_SB.WMID.GM27 ()
                    RETC = Zero
                }

                If ((CMDT == 0x28))
                {
                    Local2 = \_SB.WMID.GM28 ()
                    RETC = Zero
                }

                If ((CMDT == 0x29))
                {
                    Local2 = \_SB.WMID.GM29 ()
                    RETC = Zero
                }

                If ((CMDT == 0x2A))
                {
                    Local2 = \_SB.WMID.GM2A ()
                    RETC = Zero
                }

                If ((CMDT == 0x2B))
                {
                    Local2 = \_SB.WMID.GM2B ()
                    RETC = Zero
                }

                If ((CMDT == 0x2C))
                {
                    Local2 = \_SB.WMID.GM2C ()
                    RETC = Zero
                }

                If ((CMDT == 0x2D))
                {
                    Local2 = \_SB.WMID.GM2D ()
                    RETC = Zero
                }

                If ((CMDT == 0x2E))
                {
                    Local2 = \_SB.WMID.GM2E ()
                    RETC = Zero
                }

                If ((CMDT == 0x2F))
                {
                    Local2 = \_SB.WMID.GM2F ()
                    RETC = Zero
                }

                If ((CMDT == 0x30))
                {
                    Local2 = \_SB.WMID.GM30 ()
                    RETC = Zero
                }

                If ((CMDT == 0x31))
                {
                    Local2 = \_SB.WMID.GM31 ()
                    RETC = Zero
                }

                If ((CMDT == 0x32))
                {
                    Local2 = \_SB.WMID.GM32 ()
                    RETC = Zero
                }

                If ((CMDT == 0x33))
                {
                    Local2 = \_SB.WMID.GM33 ()
                    RETC = Zero
                }

                If ((CMDT == 0x34))
                {
                    Local2 = \_SB.WMID.GM34 ()
                    RETC = Zero
                }

                If ((CMDT == 0x35))
                {
                    Local2 = \_SB.WMID.GM35 ()
                    RETC = Zero
                }

                If ((CMDT == 0x36))
                {
                    Local2 = \_SB.WMID.GM36 ()
                    RETC = Zero
                }

                If ((CMDT == 0x37))
                {
                    Local2 = \_SB.WMID.GM37 ()
                    RETC = Zero
                }
            }

            If ((COMD == 0x00020009))
            {
                If ((CMDT == One))
                {
                    Local2 = \_SB.WMID.LM01 ()
                    RETC = Zero
                }

                If ((CMDT == 0x02))
                {
                    Local2 = \_SB.WMID.LM02 ()
                    RETC = Zero
                }

                If ((CMDT == 0x03))
                {
                    Local2 = \_SB.WMID.LM03 ()
                    RETC = Zero
                }

                If ((CMDT == 0x04))
                {
                    Local2 = \_SB.WMID.LM04 ()
                    RETC = Zero
                }

                If ((CMDT == 0x05))
                {
                    Local2 = \_SB.WMID.LM05 ()
                    RETC = Zero
                }

                If ((CMDT == 0x06))
                {
                    Local2 = \_SB.WMID.LM06 ()
                    RETC = Zero
                }

                If ((CMDT == 0x07))
                {
                    Local2 = \_SB.WMID.LM07 ()
                    RETC = Zero
                }

                If ((CMDT == 0x08))
                {
                    Local2 = \_SB.WMID.LM08 ()
                    RETC = Zero
                }

                If ((CMDT == 0x09))
                {
                    Local2 = \_SB.WMID.LM09 ()
                    RETC = Zero
                }

                If ((CMDT == 0x0A))
                {
                    Local2 = \_SB.WMID.LM0A ()
                    RETC = Zero
                }

                If ((CMDT == 0x0B))
                {
                    Local2 = \_SB.WMID.LM0B ()
                    RETC = Zero
                }
            }

            If ((COMD == 0x0002000B))
            {
                If ((CMDT == One))
                {
                    Local2 = \_SB.WMID.ACPD ()
                    RETC = Zero
                }
            }

            If ((COMD == 0x00020000))
            {
                If ((CMDT == 0x03))
                {
                    RETC = 0x04
                }

                If ((CMDT == 0x1E))
                {
                    Local2 = \_SB.WMID.GASC ()
                    RETC = Zero
                }
            }
        }

        If ((RETC == Zero))
        {
            RETC = DerefOf (Local2 [Zero])
            If ((RETC == Zero))
            {
                If ((DerefOf (Local2 [One]) <= Local0))
                {
                    Local0 = Zero
                    While ((Local0 < DerefOf (Local2 [One])))
                    {
                        Local1 [(Local0 + 0x08)] = DerefOf (DerefOf (
                            Local2 [0x02]) [Local0])
                        Local0++
                    }

                    SIOU = 0x53534150
                }
                Else
                {
                    RETC = 0x05
                }
            }
        }

        WBUF = ZOBF /* \ZOBF */
        Return (Local1)
    }

    Scope (\)
    {
        Field (EXBU, AnyAcc, Lock, Preserve)
        {
            Offset (0x00), 
            AEAX,   32, 
            AEBX,   32, 
            AECX,   32, 
            AEDX,   32, 
            AREF,   32, 
            DAB0,   8, 
            DAB1,   8, 
            DAB2,   8, 
            DAB3,   8, 
            WBUF,   8192, 
            TJMX,   8, 
            FNKY,   8, 
            CAME,   8, 
            VTDT,   8, 
            DPMD,   8, 
            WLVD,   16, 
            WLDD,   16, 
            WLSV,   16, 
            WLSS,   16, 
            BTVD,   16, 
            BTDD,   16, 
            WWVD,   16, 
            WWDD,   16, 
            WMVD,   16, 
            WMDD,   16, 
            GPVD,   16, 
            GPDD,   16, 
            SMA4,   8, 
            PMEE,   8, 
            WSD0,   8, 
            WSD1,   8, 
            WSD2,   8, 
            WSD3,   8, 
            WAR7,   8, 
            DBCM,   8, 
            CPUP,   64, 
            GPUP,   32, 
            SYSP,   64, 
            FANP,   32, 
            BAPF,   32, 
            HDDP,   32, 
            CPUT,   8, 
            GPUT,   8, 
            SYST,   8, 
            FANT,   8, 
            BATT,   8, 
            TTST,   8, 
            RTCF,   8, 
            BODD,   8, 
            BRTM,   8, 
            INBG,   8, 
            NOCD,   8, 
            PWVD,   16, 
            PWDD,   16, 
            PWSV,   16, 
            PWSS,   16, 
            YRCL,   16, 
            PBUF,   1024, 
            ADBE,   8, 
            WLSW,   8, 
            WOWL,   8, 
            HIHT,   1, 
            HIWS,   1, 
            HIPD,   1, 
            HIKL,   1, 
            HIRE,   4, 
            NOFN,   8, 
            ALCS,   8, 
            Offset (0x600), 
            SBUF,   4096
        }

        OperationRegion (PMSP, SystemIO, 0xB2, One)
        Field (PMSP, ByteAcc, NoLock, Preserve)
        {
            OSMI,   8
        }

        OperationRegion (CMS1, SystemIO, 0x72, 0x02)
        Field (CMS1, ByteAcc, NoLock, Preserve)
        {
            CMSI,   8, 
            CMSD,   8
        }

        IndexField (CMSI, CMSD, ByteAcc, NoLock, Preserve)
        {
            Offset (0xC0), 
            WLDS,   1, 
            BTDS,   1, 
            CCDS,   1, 
            WMDS,   1, 
            BNLS,   1, 
            WWLS,   1, 
            WBTS,   1, 
            BNLQ,   1, 
            Offset (0xC2), 
            THAS,   8, 
            Offset (0xC5), 
            FMOD,   1, 
            HTS4,   1, 
            Offset (0xD0), 
            CWD0,   8, 
            Offset (0xD1), 
            CWD1,   8, 
            Offset (0xD2), 
            CWD2,   8, 
            Offset (0xD3), 
            CWD3,   8, 
            Offset (0xD4), 
            CWDF,   8, 
            Offset (0xD8), 
            WWDS,   1, 
            GPDS,   1, 
                ,   1, 
                ,   1, 
            WWWS,   1, 
            WGPS,   1, 
            Offset (0xDA), 
            CWCS,   8
        }

        Method (CMSW, 2, NotSerialized)
        {
            CMSI = Arg0
            CMSD = Arg1
        }

        Method (CMSR, 1, NotSerialized)
        {
            CMSI = Arg0
            Return (CMSD) /* \CMSD */
        }

        OperationRegion (PMBR, SystemIO, 0x0800, 0x04)
        Field (PMBR, ByteAcc, NoLock, Preserve)
        {
            Offset (0x01), 
                ,   6, 
            WSTS,   1, 
            Offset (0x03), 
                ,   2, 
            RTCE,   1
        }

        Method (HPTS, 1, NotSerialized)
        {
            RTCF = RTCE /* \RTCE */
            CMSW (0xC7, Zero)
            If ((Arg0 == 0x04))
            {
                If ((OSVR >= 0x0F))
                {
                    CMSW (0xC7, 0x04)
                }
            }

            If ((Arg0 == 0x05))
            {
                If ((OSVR >= 0x0F))
                {
                    CMSW (0xC7, 0x05)
                }
            }
        }

        Method (HWAK, 1, NotSerialized)
        {
        }

        Method (CPTS, 1, NotSerialized)
        {
            \_SB.WSMI (0xEA7F, One, Arg0, Zero, Zero)
        }

        Method (CWAK, 1, Serialized)
        {
            \_SB.WSMI (0xEA7F, One, (Arg0 << 0x04), Zero, Zero)
        }

        Method (WFDA, 0, NotSerialized)
        {
            If (((AECX == Zero) || (AEBX != Zero)))
            {
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
            }
            Else
            {
                Local1 = AECX /* \AECX */
                Local0 = Package (0x03)
                    {
                        Zero, 
                        Zero, 
                        Buffer (Local1){}
                    }
            }

            Local0 [Zero] = AEBX /* \AEBX */
            If ((AEBX == Zero))
            {
                Local0 [One] = AECX /* \AECX */
                If ((AECX != Zero))
                {
                    Local1 = WBUF /* \WBUF */
                    Local2 = Zero
                    While ((Local2 < AECX))
                    {
                        DerefOf (Local0 [0x02]) [Local2] = DerefOf (Local1 [
                            Local2])
                        Local2++
                    }
                }
            }

            Return (Local0)
        }

        Method (SCMP, 2, NotSerialized)
        {
            If ((SizeOf (Arg0) < SizeOf (Arg1)))
            {
                Return (Zero)
            }

            Local0 = (SizeOf (Arg0) + One)
            Name (BUF0, Buffer (Local0){})
            Name (BUF1, Buffer (Local0){})
            BUF0 = Arg0
            BUF1 = Arg1
            While (Local0)
            {
                Local0--
                If ((DerefOf (BUF0 [Local0]) != DerefOf (BUF1 [Local0]
                    )))
                {
                    Return (Zero)
                }
            }

            Return (One)
        }

        Method (SRCM, 3, NotSerialized)
        {
            Local0 = Arg2
            Name (BUF0, Buffer (Local0){})
            Name (BUF1, Buffer (Local0){})
            BUF0 = Arg0
            BUF1 = Arg1
            While (Local0)
            {
                Local0--
                If ((DerefOf (BUF0 [Local0]) != DerefOf (BUF1 [Local0]
                    )))
                {
                    Return (Zero)
                }
            }

            Return (One)
        }

        Method (ISTR, 2, NotSerialized)
        {
            Local0 = Arg1
            Name (BUF0, Buffer (Local0){})
            Local3 = BUF0 /* \ISTR.BUF0 */
            Local2 = Zero
            While (Local0)
            {
                Local0--
                Local1 = ((Arg0 >> (Local0 << 0x02)) & 0x0F)
                Local3 [Local2] = (Local1 + 0x30)
                Local2++
            }

            Return (Local3)
        }
    }

    Scope (_SB)
    {
        Mutex (MUTS, 0x00)
        Method (WSMI, 5, NotSerialized)
        {
            Acquire (MUTS, 0xFFFF)
            If (Arg4)
            {
                Acquire (_GL, 0xFFFF)
            }

            AEAX = Arg0
            AEBX = Arg1
            AECX = Arg2
            AEDX = Arg3
            Local1 = Zero
            Local2 = AEAX /* \AEAX */
            Local3 = AEBX /* \AEBX */
            Local4 = AECX /* \AECX */
            Local5 = AEDX /* \AEDX */
            Local6 = WBUF /* \WBUF */
            Local7 = PBUF /* \PBUF */
            AREF = 0x55AA55AA
            While (((AREF == 0x55AA55AA) && (Local1 < 0x32)))
            {
                AEAX = Local2
                AEBX = Local3
                AECX = Local4
                AEDX = Local5
                WBUF = Local6
                PBUF = Local7
                OSMI = WMIX /* \WMIX */
                Sleep (0x05)
                Local1++
            }

            Local0 = AREF /* \AREF */
            If (Arg4)
            {
                Release (_GL)
            }

            Release (MUTS)
            Return (Local0)
        }
    }

    Scope (_SB)
    {
        Name (N00E, Buffer (One){})
        Device (WMID)
        {
            Name (_HID, "PNP0C14" /* Windows Management Instrumentation Device */)  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Name (WMIF, Zero)
            Name (WEI0, Zero)
            Name (WED0, Zero)
            Name (WEI1, Zero)
            Name (WED1, Zero)
            Name (WEVI, Zero)
            Name (WEVD, Zero)
            Name (HMFM, Zero)
            Name (BUFF, Buffer (0x04)
            {
                 0x00, 0x00, 0x00, 0x00                           // ....
            })
            CreateByteField (BUFF, Zero, OB0)
            CreateByteField (BUFF, One, OB1)
            CreateByteField (BUFF, 0x02, OB2)
            CreateByteField (BUFF, 0x03, OB3)
            Name (WMBF, Buffer (0x80)
            {
                 0x00                                             // .
            })
            CreateByteField (WMBF, Zero, HWB0)
            CreateByteField (WMBF, One, HWB1)
            CreateByteField (WMBF, 0x02, HWB2)
            CreateByteField (WMBF, 0x03, HWB3)
            Name (CTGP, Zero)
            Mutex (MUTZ, 0x00)
            Name (_WDG, Buffer (0x0118)
            {
                /* 0000 */  0x34, 0xF0, 0xB7, 0x5F, 0x63, 0x2C, 0xE9, 0x45,  // 4.._c,.E
                /* 0008 */  0xBE, 0x91, 0x3D, 0x44, 0xE2, 0xC7, 0x07, 0xE4,  // ..=D....
                /* 0010 */  0x41, 0x41, 0x01, 0x02, 0x79, 0x42, 0xF2, 0x95,  // AA..yB..
                /* 0018 */  0x7B, 0x4D, 0x34, 0x43, 0x93, 0x87, 0xAC, 0xCD,  // {M4C....
                /* 0020 */  0xC6, 0x7E, 0xF6, 0x1C, 0x80, 0x00, 0x01, 0x08,  // .~......
                /* 0028 */  0x18, 0x43, 0x81, 0x2B, 0xE8, 0x4B, 0x07, 0x47,  // .C.+.K.G
                /* 0030 */  0x9D, 0x84, 0xA1, 0x90, 0xA8, 0x59, 0xB5, 0xD0,  // .....Y..
                /* 0038 */  0xA0, 0x00, 0x01, 0x08, 0x21, 0x12, 0x90, 0x05,  // ....!...
                /* 0040 */  0x66, 0xD5, 0xD1, 0x11, 0xB2, 0xF0, 0x00, 0xA0,  // f.......
                /* 0048 */  0xC9, 0x06, 0x29, 0x10, 0x41, 0x42, 0x01, 0x00,  // ..).AB..
                /* 0050 */  0xEB, 0x91, 0x4C, 0x1F, 0x5C, 0xDC, 0x0B, 0x46,  // ..L.\..F
                /* 0058 */  0x95, 0x1D, 0xC7, 0xCB, 0x9B, 0x4B, 0x8D, 0x5E,  // .....K.^
                /* 0060 */  0x42, 0x41, 0x01, 0x02, 0x49, 0x4B, 0x11, 0x2D,  // BA..IK.-
                /* 0068 */  0xFB, 0x2D, 0x30, 0x41, 0xB8, 0xFE, 0x4A, 0x3C,  // .-0A..J<
                /* 0070 */  0x09, 0xE7, 0x51, 0x33, 0x42, 0x43, 0x5D, 0x00,  // ..Q3BC].
                /* 0078 */  0xE3, 0x08, 0x8D, 0x98, 0xF4, 0x68, 0x35, 0x4C,  // .....h5L
                /* 0080 */  0xAF, 0x3E, 0x6A, 0x1B, 0x81, 0x06, 0xF8, 0x3C,  // .>j....<
                /* 0088 */  0x42, 0x44, 0x1E, 0x00, 0x46, 0x97, 0xEA, 0x14,  // BD..F...
                /* 0090 */  0x1F, 0xCE, 0x98, 0x40, 0xA0, 0xE0, 0x70, 0x45,  // ...@..pE
                /* 0098 */  0xCB, 0x4D, 0xA7, 0x45, 0x42, 0x45, 0x02, 0x00,  // .M.EBE..
                /* 00A0 */  0x28, 0x20, 0x2F, 0x32, 0x84, 0x0F, 0x01, 0x49,  // ( /2...I
                /* 00A8 */  0x98, 0x8E, 0x01, 0x51, 0x76, 0x04, 0x9E, 0x2D,  // ...Qv..-
                /* 00B0 */  0x42, 0x46, 0x01, 0x00, 0x3D, 0xDE, 0x32, 0x82,  // BF..=.2.
                /* 00B8 */  0x3D, 0x66, 0x27, 0x43, 0xA8, 0xF4, 0xE2, 0x93,  // =f'C....
                /* 00C0 */  0xAD, 0xB9, 0xBF, 0x05, 0x42, 0x47, 0x01, 0x00,  // ....BG..
                /* 00C8 */  0x36, 0x64, 0x1F, 0x8F, 0x42, 0x9F, 0xC8, 0x42,  // 6d..B..B
                /* 00D0 */  0xBA, 0xDC, 0x0E, 0x94, 0x24, 0xF2, 0x0C, 0x9A,  // ....$...
                /* 00D8 */  0x42, 0x48, 0x00, 0x00, 0x35, 0x64, 0x1F, 0x8F,  // BH..5d..
                /* 00E0 */  0x42, 0x9F, 0xC8, 0x42, 0xBA, 0xDC, 0x0E, 0x94,  // B..B....
                /* 00E8 */  0x24, 0xF2, 0x0C, 0x9A, 0x42, 0x49, 0x00, 0x00,  // $...BI..
                /* 00F0 */  0x61, 0xA6, 0x91, 0x73, 0x3A, 0x22, 0xDB, 0x47,  // a..s:".G
                /* 00F8 */  0xA7, 0x7A, 0x7B, 0xE8, 0x4C, 0x60, 0x82, 0x2D,  // .z{.L`.-
                /* 0100 */  0x41, 0x43, 0x00, 0x02, 0xB6, 0x63, 0x4E, 0xDF,  // AC...cN.
                /* 0108 */  0xBC, 0x3B, 0x58, 0x48, 0x97, 0x37, 0xC7, 0x4F,  // .;XH.7.O
                /* 0110 */  0x82, 0xF8, 0x21, 0xF3, 0x42, 0x4A, 0x00, 0x00   // ..!.BJ..
            })
            Name (EVNT, Package (0x03)
            {
                Package (0x05)
                {
                    "BIOS Configuration Change", 
                    "BIOS Settings", 
                    0x04, 
                    0x05, 
                    0x02
                }, 

                Package (0x05)
                {
                    "BIOS Configuration Security", 
                    "An attempt has been made to Access BIOS features unsuccessfully", 
                    0x04, 
                    0x0A, 
                    0x06
                }, 

                Package (0x05)
                {
                    "Unknown Event", 
                    "Unknown event type", 
                    Zero, 
                    Zero, 
                    Zero
                }
            })
            Name (N00F, One)
            Method (M000, 0, Serialized)
            {
                If (N00F)
                {
                    Local7 = DerefOf (N00A [Zero])
                    Local3 = SizeOf (Local7)
                    Local0 = Zero
                    While ((Local0 < 0x5D))
                    {
                        Local6 = DerefOf (DerefOf (N00A [Local0]) [Zero])
                        Local2 = DerefOf (DerefOf (N00A [Local0]) [0x0D])
                        If ((Local2 == Zero))
                        {
                            DerefOf (N00A [Local0]) [Zero] = " "
                        }

                        Local2 += 0x0E
                        While ((Local2 < Local3))
                        {
                            DerefOf (N00A [Local0]) [Local2] = ""
                            Local2++
                        }

                        Local0++
                    }

                    N00F = Zero
                }
            }

            Method (WMAA, 3, Serialized)
            {
                Acquire (MUTZ, 0xFFFF)
                Local0 = HWMC (Arg1, Arg2)
                Release (MUTZ)
                Return (Local0)
            }

            Name (WMI5, Zero)
            Method (W05W, 1, NotSerialized)
            {
                WMI5 = 0x05
                Local0 = (Arg0 * 0x0A)
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    Divide (Local0, 0x0100, Local2, Local1)
                    ^^PCI0.SBRG.EC0.DLTH = Local1
                    ^^PCI0.SBRG.EC0.DLTL = Local2
                }
            }

            Method (ABES, 0, NotSerialized)
            {
                Local0 = Zero
                Local0 = ^^PCI0.SBRG.EC0.RC57 /* \_SB_.PCI0.SBRG.EC0_.RC57 */
                Return (Local0)
            }

            Method (GDST, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x1 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00, 0x00, 0x00, 0x00                           // ....
                        }
                    }
                Return (Local0)
            }

            Method (SDST, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x1 (BIOS Write)"
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (GDKS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x04 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        One, 
                        Buffer (One)
                        {
                             0x00                                             // .
                        }
                    }
                Return (Local0)
            }

            Method (GWLS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x05 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00                                             // .
                        }
                    }
                Return (Local0)
            }

            Method (SWLS, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x5 (BIOS Write)"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = Zero
                Local2 = DerefOf (Arg0 [Local1])
                Return (Local0)
            }

            Method (GBIF, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x7 (BIOS Read)"
                If (!^^PCI0.SBRG.EC0.ECON)
                {
                    Local0 = Package (0x02)
                        {
                            0x0D, 
                            Zero
                        }
                    Sleep (0x96)
                    Return (Local0)
                }

                If (Arg0)
                {
                    Local0 = Package (0x02)
                        {
                            0x06, 
                            Zero
                        }
                    Sleep (0x96)
                    Return (Local0)
                }

                If (!^^PCI0.SBRG.EC0.RA40)
                {
                    Local0 = Package (0x02)
                        {
                            0x34, 
                            Zero
                        }
                    Sleep (0x96)
                    Return (Local0)
                }
                ElseIf (^^PCI0.SBRG.EC0.R696)
                {
                    Local1 = ^^PCI0.SBRG.EC0.R820 /* \_SB_.PCI0.SBRG.EC0_.R820 */
                    Local2 = ^^PCI0.SBRG.EC0.RA60 /* \_SB_.PCI0.SBRG.EC0_.RA60 */
                    If (((Local1 & 0x02) & (Local2 == 0x19)))
                    {
                        Local0 = Package (0x02)
                            {
                                0x36, 
                                Zero
                            }
                        Sleep (0x96)
                        Return (Local0)
                    }
                    ElseIf (((Local1 & One) & (Local2 == 0x1A)))
                    {
                        Local0 = Package (0x02)
                            {
                                0x36, 
                                Zero
                            }
                        Sleep (0x96)
                        Return (Local0)
                    }
                }
                Else
                {
                    Local0 = Package (0x02)
                        {
                            0x37, 
                            Zero
                        }
                    Sleep (0x96)
                    Return (Local0)
                }

                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80){}
                    }
                Local1 = ^^PCI0.SBRG.EC0.R700 /* \_SB_.PCI0.SBRG.EC0_.R700 */
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [One] = Zero
                    DerefOf (Local0 [0x02]) [Zero] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [One])
                    DerefOf (Local0 [0x02]) [Zero] = Local2
                }

                Local1 = ^^PCI0.SBRG.EC0.R720 /* \_SB_.PCI0.SBRG.EC0_.R720 */
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x03] = Zero
                    DerefOf (Local0 [0x02]) [0x02] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x03])
                    DerefOf (Local0 [0x02]) [0x02] = Local2
                }

                Local1 = ^^PCI0.SBRG.EC0.R850 /* \_SB_.PCI0.SBRG.EC0_.R850 */
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x05] = Zero
                    DerefOf (Local0 [0x02]) [0x04] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x05])
                    DerefOf (Local0 [0x02]) [0x04] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x0C, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x07] = Zero
                    DerefOf (Local0 [0x02]) [0x06] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x07])
                    DerefOf (Local0 [0x02]) [0x06] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x17, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x09] = Zero
                    DerefOf (Local0 [0x02]) [0x08] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x09])
                    DerefOf (Local0 [0x02]) [0x08] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x08, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x0B] = Zero
                    DerefOf (Local0 [0x02]) [0x0A] = Zero
                }
                Else
                {
                    Local1 -= 0x0AAA
                    Divide (Local1, 0x0A, Local2, Local1)
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x0B])
                    DerefOf (Local0 [0x02]) [0x0A] = Local2
                }

                Local1 = ^^PCI0.SBRG.EC0.R870 /* \_SB_.PCI0.SBRG.EC0_.R870 */
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x0D] = Zero
                    DerefOf (Local0 [0x02]) [0x0C] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x0D])
                    DerefOf (Local0 [0x02]) [0x0C] = Local2
                }

                Local1 = ^^PCI0.SBRG.EC0.R830 /* \_SB_.PCI0.SBRG.EC0_.R830 */
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x0F] = Zero
                    DerefOf (Local0 [0x02]) [0x0E] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x0F])
                    DerefOf (Local0 [0x02]) [0x0E] = Local2
                }

                Local1 = ^^PCI0.SBRG.EC0.R740 /* \_SB_.PCI0.SBRG.EC0_.R740 */
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x11] = Zero
                    DerefOf (Local0 [0x02]) [0x10] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x11])
                    DerefOf (Local0 [0x02]) [0x10] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x16, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x13] = Zero
                    DerefOf (Local0 [0x02]) [0x12] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x13])
                    DerefOf (Local0 [0x02]) [0x12] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x3F, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x15] = Zero
                    DerefOf (Local0 [0x02]) [0x14] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x15])
                    DerefOf (Local0 [0x02]) [0x14] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x3E, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x17] = Zero
                    DerefOf (Local0 [0x02]) [0x16] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x17])
                    DerefOf (Local0 [0x02]) [0x16] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x3D, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x19] = Zero
                    DerefOf (Local0 [0x02]) [0x18] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x19])
                    DerefOf (Local0 [0x02]) [0x18] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x3C, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x1B] = Zero
                    DerefOf (Local0 [0x02]) [0x1A] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x1B])
                    DerefOf (Local0 [0x02]) [0x1A] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x1C, RefOf (Local1))
                Local3 = ITOS (ToBCD (Local1))
                Local2 = 0x1C
                Local4 = Zero
                Local1 = SizeOf (Local3)
                While (Local1)
                {
                    GBFE (Local3, Local4, RefOf (Local5))
                    PBFE (DerefOf (Local0 [0x02]), Local2, Local5)
                    Local1--
                    Local2++
                    Local4++
                }

                DerefOf (Local0 [0x02]) [Local2] = 0x20
                Local2++
                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x1B, RefOf (Local1))
                Local7 = (Local1 & 0x1F)
                Local6 = ITOS (ToBCD (Local7))
                Local7 = (Local1 & 0x01E0)
                Local7 >>= 0x05
                Local5 = ITOS (ToBCD (Local7))
                Local7 = (Local1 >> 0x09)
                Local7 += 0x07BC
                Local4 = ITOS (ToBCD (Local7))
                Local1 = 0x02
                Local7 = 0x03
                While (Local1)
                {
                    GBFE (Local5, Local7, RefOf (Local3))
                    PBFE (DerefOf (Local0 [0x02]), Local2, Local3)
                    Local1--
                    Local2++
                    Local7++
                }

                DerefOf (Local0 [0x02]) [Local2] = "/"
                Local2++
                Local1 = 0x02
                Local7 = 0x03
                While (Local1)
                {
                    GBFE (Local6, Local7, RefOf (Local3))
                    PBFE (DerefOf (Local0 [0x02]), Local2, Local3)
                    Local1--
                    Local2++
                    Local7++
                }

                DerefOf (Local0 [0x02]) [Local2] = "/"
                Local2++
                Local1 = 0x04
                Local7 = One
                While (Local1)
                {
                    GBFE (Local4, Local7, RefOf (Local3))
                    PBFE (DerefOf (Local0 [0x02]), Local2, Local3)
                    Local1--
                    Local2++
                    Local7++
                }

                DerefOf (Local0 [0x02]) [Local2] = Zero
                ^^PCI0.SBRG.EC0.SMRD (0x0B, 0x16, 0x20, RefOf (Local1))
                Local3 = SizeOf (Local1)
                Local2 = 0x2C
                Local4 = Zero
                While (Local3)
                {
                    GBFE (Local1, Local4, RefOf (Local5))
                    PBFE (DerefOf (Local0 [0x02]), Local2, Local5)
                    Local3--
                    Local2++
                    Local4++
                }

                ^^PCI0.SBRG.EC0.SMRD (0x0B, 0x16, 0x70, RefOf (Local1))
                GBFE (Local1, Zero, RefOf (Local5))
                If ((Local5 == 0x36))
                {
                    Local3 = SizeOf (Local1)
                    Local2 = 0x3E
                    Local4 = Zero
                }
                Else
                {
                    Local3 = 0x03
                    Local2 = 0x3E
                    Local4 = Zero
                    Local1 = Buffer (0x04)
                        {
                            "N/A"
                        }
                }

                While (Local3)
                {
                    GBFE (Local1, Local4, RefOf (Local5))
                    PBFE (DerefOf (Local0 [0x02]), Local2, Local5)
                    Local3--
                    Local2++
                    Local4++
                }

                ^^PCI0.SBRG.EC0.SMRD (0x0B, 0x16, 0x21, RefOf (Local1))
                Local3 = SizeOf (Local1)
                Local2 = 0x4F
                Local4 = Zero
                While (Local3)
                {
                    GBFE (Local1, Local4, RefOf (Local5))
                    PBFE (DerefOf (Local0 [0x02]), Local2, Local5)
                    Local3--
                    Local2++
                    Local4++
                }

                ^^PCI0.SBRG.EC0.SMRD (0x0B, 0x16, 0x22, RefOf (Local1))
                Local3 = SizeOf (Local1)
                Local2 = 0x56
                Local4 = Zero
                While (Local3)
                {
                    GBFE (Local1, Local4, RefOf (Local5))
                    PBFE (DerefOf (Local0 [0x02]), Local2, Local5)
                    Local3--
                    Local2++
                    Local4++
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, Zero, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x5B] = Zero
                    DerefOf (Local0 [0x02]) [0x5A] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x5B])
                    DerefOf (Local0 [0x02]) [0x5A] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x1B, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x5D] = Zero
                    DerefOf (Local0 [0x02]) [0x5C] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x5D])
                    DerefOf (Local0 [0x02]) [0x5C] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x14, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x5F] = Zero
                    DerefOf (Local0 [0x02]) [0x5E] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x5F])
                    DerefOf (Local0 [0x02]) [0x5E] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x15, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x61] = Zero
                    DerefOf (Local0 [0x02]) [0x60] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x61])
                    DerefOf (Local0 [0x02]) [0x60] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x0B, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x63] = Zero
                    DerefOf (Local0 [0x02]) [0x62] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x63])
                    DerefOf (Local0 [0x02]) [0x62] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x11, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x65] = Zero
                    DerefOf (Local0 [0x02]) [0x64] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x65])
                    DerefOf (Local0 [0x02]) [0x64] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x12, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x67] = Zero
                    DerefOf (Local0 [0x02]) [0x66] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x67])
                    DerefOf (Local0 [0x02]) [0x66] = Local2
                }

                ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x13, RefOf (Local1))
                If ((Local1 == Zero))
                {
                    DerefOf (Local0 [0x02]) [0x69] = Zero
                    DerefOf (Local0 [0x02]) [0x68] = Zero
                }
                Else
                {
                    Divide (Local1, 0x0100, Local2, DerefOf (Local0 [0x02]) [0x69])
                    DerefOf (Local0 [0x02]) [0x68] = Local2
                }

                DerefOf (Local0 [0x02]) [0x6A] = One
                Sleep (0x96)
                Local2 = Zero
                If (((^^PCI0.SBRG.EC0.RC51 == One) & (^^PCI0.SBRG.EC0.RC56 != One)))
                {
                    Local2 |= One
                }

                If (((^^PCI0.SBRG.EC0.RC52 == One) & (^^PCI0.SBRG.EC0.RC56 != One)))
                {
                    Local2 |= One
                }

                Local2 |= (BSSE << One)
                Local2 |= (ABES () << 0x02)
                DerefOf (Local0 [0x02]) [0x6B] = Local2
                Return (Local0)
            }

            Method (GBBT, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x8 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80)
                        {
                            /* 0000 */  0x31, 0x01, 0x9B, 0x01, 0xAE, 0x01, 0xB6, 0x01,  // 1.......
                            /* 0008 */  0xB7, 0x01, 0x9C, 0x21, 0xA1, 0x21, 0xA8, 0x21,  // ...!.!.!
                            /* 0010 */  0xFF, 0xFF, 0x00, 0x00                           // ....
                        }
                    }
                Return (Local0)
            }

            Method (GHKS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x9 (BIOS Read)"
                Acquire (^^PCI0.SBRG.EC0.MUT1, 0xFFFF)
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    DerefOf (Local0 [0x02]) [Zero] = ^^PCI0.SBRG.EC0.RE60 /* \_SB_.PCI0.SBRG.EC0_.RE60 */
                }

                Release (^^PCI0.SBRG.EC0.MUT1)
                Return (Local0)
            }

            Method (SHKS, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x9 (BIOS Write)"
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    Acquire (^^PCI0.SBRG.EC0.MUT1, 0xFFFF)
                    If (^^PCI0.SBRG.EC0.ECON)
                    {
                        ^^PCI0.SBRG.EC0.RE60 = Arg0
                    }

                    Release (^^PCI0.SBRG.EC0.MUT1)
                }

                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (GHKF, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0xA (BIOS Read)"
                Return (HKFR ())
            }

            Method (SHKF, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0xA (BIOS Write)"
                Local1 = (Arg0 & 0xFF)
                Local3 = (Arg0 & 0xFF00)
                Local2 = (Local3 >> 0x08)
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                DerefOf (Local0 [0x02]) [Zero] = Local1
                DerefOf (Local0 [0x02]) [One] = Local2
                Return (Local0)
            }

            Method (HKFR, 0, NotSerialized)
            {
                Acquire (^^PCI0.SBRG.EC0.MUT1, 0xFFFF)
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    Local1 = ^^PCI0.SBRG.EC0.RA00 /* \_SB_.PCI0.SBRG.EC0_.RA00 */
                    ^^PCI0.SBRG.EC0.QBHK = Zero
                }
                Else
                {
                    Local1 = Zero
                }

                If ((Local1 == 0x0D))
                {
                    Debug = "Fn+ESC Pressed"
                    DerefOf (Local0 [0x02]) [Zero] = 0x31
                    DerefOf (Local0 [0x02]) [One] = One
                }

                If ((Local1 == One))
                {
                    Debug = "Fn+F1 Pressed"
                    DerefOf (Local0 [0x02]) [Zero] = 0x9B
                    DerefOf (Local0 [0x02]) [One] = One
                }

                If ((Local1 == 0x02))
                {
                    Debug = "Fn+F2 Pressed"
                    ^^PCI0.SBRG.EC0._Q10 ()
                    Sleep (0x32)
                    DerefOf (Local0 [0x02]) [Zero] = Zero
                    DerefOf (Local0 [0x02]) [One] = Zero
                }

                If ((Local1 == 0x03))
                {
                    Debug = "Fn+F3 Pressed"
                    ^^PCI0.SBRG.EC0._Q11 ()
                    Sleep (0x32)
                    DerefOf (Local0 [0x02]) [Zero] = Zero
                    DerefOf (Local0 [0x02]) [One] = Zero
                }

                If ((Local1 == 0x04))
                {
                    Debug = "Fn+F4 Pressed"
                    DerefOf (Local0 [0x02]) [Zero] = 0xAE
                    DerefOf (Local0 [0x02]) [One] = One
                }

                If ((Local1 == 0x06))
                {
                    Debug = "Fn+F6 Pressed"
                    DerefOf (Local0 [0x02]) [Zero] = 0x9D
                    DerefOf (Local0 [0x02]) [One] = One
                }

                If ((Local1 == 0x0B))
                {
                    Debug = "Fn+B Pressed"
                    DerefOf (Local0 [0x02]) [Zero] = 0x9C
                    DerefOf (Local0 [0x02]) [One] = 0x21
                }

                Release (^^PCI0.SBRG.EC0.MUT1)
                Return (Local0)
            }

            Method (GBBV, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0xC (BIOS Read)"
                Acquire (^^PCI0.SBRG.EC0.MUT1, 0xFFFF)
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    Local1 = ^^PCI0.SBRG.EC0.RA20 /* \_SB_.PCI0.SBRG.EC0_.RA20 */
                }
                Else
                {
                    Local1 = Zero
                }

                If ((Local1 == 0x20))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x8D
                    DerefOf (Local0 [0x02]) [One] = 0x21
                }

                If ((Local1 == 0x21))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x8E
                    DerefOf (Local0 [0x02]) [One] = 0x21
                }

                If ((Local1 == 0x22))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x8F
                    DerefOf (Local0 [0x02]) [One] = 0x21
                }

                If ((Local1 == 0x23))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x90
                    DerefOf (Local0 [0x02]) [One] = 0x21
                }

                If ((Local1 == 0x24))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x91
                    DerefOf (Local0 [0x02]) [One] = 0x21
                }

                If ((Local1 == 0x25))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x92
                    DerefOf (Local0 [0x02]) [One] = 0x21
                }

                If ((Local1 == 0x26))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x93
                    DerefOf (Local0 [0x02]) [One] = 0x21
                }

                If ((Local1 == 0x40))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0xA9
                    DerefOf (Local0 [0x02]) [One] = 0x21
                    DerefOf (Local0 [0x02]) [0x02] = One
                }

                If ((Local1 == 0x41))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0xA9
                    DerefOf (Local0 [0x02]) [One] = 0x21
                    DerefOf (Local0 [0x02]) [0x02] = Zero
                }

                If ((Local1 == 0x42))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0xA4
                    DerefOf (Local0 [0x02]) [One] = 0x21
                    DerefOf (Local0 [0x02]) [0x02] = One
                }

                If ((Local1 == 0x43))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0xA4
                    DerefOf (Local0 [0x02]) [One] = 0x21
                    DerefOf (Local0 [0x02]) [0x02] = Zero
                }

                If ((Local1 == 0x44))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0xA5
                    DerefOf (Local0 [0x02]) [One] = 0x21
                }

                If ((Local1 == 0x45))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0xA6
                    DerefOf (Local0 [0x02]) [One] = 0x21
                }

                If ((Local1 == 0x08))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x70
                    DerefOf (Local0 [0x02]) [One] = 0x02
                }

                Release (^^PCI0.SBRG.EC0.MUT1)
                Return (Local0)
            }

            Method (GFRC, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x0D (BIOS Read)"
                Local0 = Zero
                Local1 = Zero
                Local2 = Zero
                Local3 = Zero
                Local4 = Zero
                Local5 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80){}
                    }
                Local0 |= 0x02
                Local0 |= 0x10
                Local0 |= 0x20
                If (CAME)
                {
                    Local0 |= 0x80
                }

                If ((VTDT != Zero))
                {
                    Local1 |= One
                }

                Local1 |= 0x08
                Local1 |= 0x10
                Local2 |= One
                Local2 |= 0x20
                Local3 |= 0x04
                Local3 |= 0x80
                Local4 |= 0x02
                Local6 = Zero
                Local6 |= Zero
                DerefOf (Local5 [0x02]) [Zero] = Local0
                DerefOf (Local5 [0x02]) [One] = Local1
                DerefOf (Local5 [0x02]) [0x02] = Local2
                DerefOf (Local5 [0x02]) [0x03] = Local3
                DerefOf (Local5 [0x02]) [0x04] = Local4
                DerefOf (Local5 [0x02]) [0x06] = Local6
                Return (Local5)
            }

            Method (GSAS, 0, Serialized)
            {
                Debug = "HP WMI Command 0x0F (BIOS Read)"
                Local0 = Zero
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    If ((^^PCI0.SBRG.EC0.R403 == One))
                    {
                        Local0 = ^^PCI0.SBRG.EC0.RAD0 /* \_SB_.PCI0.SBRG.EC0_.RAD0 */
                        If ((Local0 <= One))
                        {
                            Local0 = One
                        }
                        ElseIf ((Local0 == 0x02))
                        {
                            Local0 = 0x02
                        }
                        ElseIf ((Local0 >= 0x04))
                        {
                            Local0 = 0x04
                        }

                        Local1 = ^^PCI0.SBRG.EC0.R6C0 /* \_SB_.PCI0.SBRG.EC0_.R6C0 */
                        If ((Local1 == One))
                        {
                            Local0 = 0x05
                        }
                    }
                    ElseIf ((^^PCI0.SBRG.EC0.R405 == One))
                    {
                        Local0 = 0x02
                    }
                    Else
                    {
                        Local0 = One
                    }
                }

                Local1 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00, 0x00, 0x00, 0x00                           // ....
                        }
                    }
                DerefOf (Local1 [0x02]) [Zero] = Local0
                Local3 = 0x2E
                Local3 |= 0x80
                DerefOf (Local1 [0x02]) [One] = Local3
                Switch (^^PCI0.SBRG.EC0.RA30)
                {
                    Case (One)
                    {
                        DerefOf (Local1 [0x02]) [0x03] = One
                    }
                    Case (0x02)
                    {
                        DerefOf (Local1 [0x02]) [0x03] = 0x03
                    }
                    Case (0x03)
                    {
                        DerefOf (Local1 [0x02]) [0x03] = 0x06
                    }
                    Case (0x04)
                    {
                        DerefOf (Local1 [0x02]) [0x03] = 0x09
                    }
                    Case (0x05)
                    {
                        DerefOf (Local1 [0x02]) [0x03] = 0x0D
                    }
                    Case (0x06)
                    {
                        DerefOf (Local1 [0x02]) [0x03] = 0x12
                    }
                    Case (0x07)
                    {
                        DerefOf (Local1 [0x02]) [0x03] = 0x14
                    }
                    Default
                    {
                        DerefOf (Local1 [0x02]) [0x03] = 0x09
                    }

                }

                Return (Local1)
            }

            Method (GWSD, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x10 (BIOS Read)"
                WSMI (One, 0x10, Zero, 0x08, Zero)
                Return (WFDA ())
            }

            Method (SWSD, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x10 (BIOS Write)"
                WSMI (0x02, 0x10, 0x08, Zero, Zero)
                Return (WFDA ())
            }

            Method (GWDI, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x1B (BIOS Read)"
                WMIF = One
                Local0 = Buffer (0x10){}
                OB0 = 0x10
                OB1 = Zero
                Local0 [Zero] = One
                Local0 [One] = Zero
                Local0 [0x02] = Zero
                Local0 [0x03] = Zero
                Local0 [0x04] = Zero
                Local0 [0x05] = Zero
                Local1 = (WLDS + BTDS) /* \BTDS */
                Local1 += WWDS /* \WWDS */
                Local0 [0x06] = Local1
                If (((CCDS == One) || (WMDS == One)))
                {
                    Local1 += One
                }

                Local0 [0x07] = Local1
                Local0 [0x08] = Zero
                Local0 [0x09] = Zero
                Local0 [0x0A] = Zero
                Local0 [0x0B] = Zero
                Local0 [0x0C] = Zero
                Local0 [0x0D] = Zero
                Local0 [0x0E] = Zero
                Local0 [0x0F] = Zero
                If ((WLDS == One))
                {
                    Local1 = Buffer (0x10){}
                    Local1 [Zero] = Zero
                    Local1 [One] = Zero
                    Local1 [0x02] = (WLVD & 0xFF)
                    Local1 [0x03] = (WLVD >> 0x08)
                    Local1 [0x04] = (WLDD & 0xFF)
                    Local1 [0x05] = (WLDD >> 0x08)
                    Local1 [0x06] = (WLSV & 0xFF)
                    Local1 [0x07] = (WLSV >> 0x08)
                    Local1 [0x08] = (WLSS & 0xFF)
                    Local1 [0x09] = (WLSS >> 0x08)
                    Local1 [0x0A] = OB1 /* \_SB_.WMID.OB1_ */
                    Local2 = Zero
                    Local2 |= (WWLS << One)
                    Local2 |= 0x04
                    Local2 |= (BNLS << 0x03)
                    Local1 [0x0B] = Local2
                    Local1 [0x0C] = Zero
                    Local1 [0x0D] = Zero
                    Local1 [0x0E] = Zero
                    Local1 [0x0F] = Zero
                    OB0 += 0x10
                    Concatenate (Local0, Local1, Local0)
                }

                If ((CCDS == One))
                {
                    Local1 = Buffer (0x10){}
                    Local1 [Zero] = One
                    Local1 [One] = One
                    Local1 [0x02] = (BTVD & 0xFF)
                    Local1 [0x03] = (BTVD >> 0x08)
                    Local1 [0x04] = (BTDD & 0xFF)
                    Local1 [0x05] = (BTDD >> 0x08)
                    Local1 [0x06] = Zero
                    Local1 [0x07] = Zero
                    Local1 [0x08] = Zero
                    Local1 [0x09] = Zero
                    Local1 [0x0A] = OB1 /* \_SB_.WMID.OB1_ */
                    Local2 = Zero
                    Local2 |= (WWLS << One)
                    Local2 |= 0x04
                    Local2 |= (BNLS << 0x03)
                    Local1 [0x0B] = Local2
                    Local1 [0x0C] = Zero
                    Local1 [0x0D] = Zero
                    Local1 [0x0E] = Zero
                    Local1 [0x0F] = Zero
                    OB0 += 0x10
                    Concatenate (Local0, Local1, Local0)
                }

                If ((WMDS == One))
                {
                    Local1 = Buffer (0x10){}
                    Local1 [Zero] = 0x02
                    Local1 [One] = One
                    Local1 [0x02] = (WMVD & 0xFF)
                    Local1 [0x03] = (WMVD >> 0x08)
                    Local1 [0x04] = (WMDD & 0xFF)
                    Local1 [0x05] = (WMDD >> 0x08)
                    Local1 [0x06] = Zero
                    Local1 [0x07] = Zero
                    Local1 [0x08] = Zero
                    Local1 [0x09] = Zero
                    Local1 [0x0A] = OB1 /* \_SB_.WMID.OB1_ */
                    Local2 = Zero
                    Local2 |= (WWLS << One)
                    Local2 |= 0x04
                    Local2 |= (BNLS << 0x03)
                    Local1 [0x0B] = Local2
                    Local1 [0x0C] = Zero
                    Local1 [0x0D] = Zero
                    Local1 [0x0E] = Zero
                    Local1 [0x0F] = Zero
                    OB0 += 0x10
                    Concatenate (Local0, Local1, Local0)
                }

                OB1++
                If ((BTDS == One))
                {
                    Local1 = Buffer (0x10){}
                    Local1 [Zero] = One
                    Local1 [One] = One
                    Local1 [0x02] = (BTVD & 0xFF)
                    Local1 [0x03] = (BTVD >> 0x08)
                    Local1 [0x04] = (BTDD & 0xFF)
                    Local1 [0x05] = (BTDD >> 0x08)
                    Local1 [0x06] = Zero
                    Local1 [0x07] = Zero
                    Local1 [0x08] = Zero
                    Local1 [0x09] = Zero
                    Local1 [0x0A] = OB1 /* \_SB_.WMID.OB1_ */
                    Local2 = Zero
                    Local2 |= (WBTS << One)
                    Local2 |= 0x04
                    Local2 |= (BNLS << 0x03)
                    Local1 [0x0B] = Local2
                    Local1 [0x0C] = Zero
                    Local1 [0x0D] = Zero
                    Local1 [0x0E] = Zero
                    Local1 [0x0F] = Zero
                    OB0 += 0x10
                    Concatenate (Local0, Local1, Local0)
                }

                Local1 = Package (0x03){}
                Local1 [Zero] = Zero
                Local1 [One] = OB0 /* \_SB_.WMID.OB0_ */
                Local1 [0x02] = Local0
                Return (Local1)
            }

            Method (SWDS, 4, NotSerialized)
            {
                Debug = "HP WMI Command 0x1B (BIOS Write)"
                If ((BNLS == One))
                {
                    If (((Arg2 == Zero) & (WLDS == One)))
                    {
                        WWLS = Arg3
                    }

                    If (((Arg2 == One) & (BTDS == One)))
                    {
                        WBTS = Arg3
                    }

                    If (((Arg2 == One) & (WWDS == One)))
                    {
                        WWWS = Arg3
                    }
                }

                If (((Arg2 == 0xFE) || (Arg2 == 0xFF)))
                {
                    WWLS = Arg3
                    WBTS = Arg3
                    WWWS = Arg3
                    BNLS = Arg3
                }

                UPWS ()
                GWEV (0x05, Zero)
                Sleep (0x0BB8)
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (GSDC, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x1D (BIOS Read)"
                WSMI (One, 0x1D, Zero, 0x04, Zero)
                Return (WFDA ())
            }

            Method (SSDC, 4, NotSerialized)
            {
                Debug = "HP WMI Command 0x1D (BIOS Write)"
                WSMI (0x02, 0x1D, 0x04, Zero, Zero)
                Return (WFDA ())
            }

            Method (GBUS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x1E (BIOS Read)"
                WSMI (One, 0x1E, Zero, 0x04, Zero)
                Return (WFDA ())
            }

            Method (SBUS, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x1E (BIOS Write)"
                WSMI (0x02, 0x1E, 0x04, Zero, Zero)
                Return (WFDA ())
            }

            Method (GBCC, 0, Serialized)
            {
                Debug = "HP WMI Command 0x1F (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    If ((^^PCI0.SBRG.EC0.RA40 == One))
                    {
                        Local1 = Zero
                        Local2 = ^^PCI0.SBRG.EC0.RA60 /* \_SB_.PCI0.SBRG.EC0_.RA60 */
                        If (((Local2 & 0x18) == 0x18))
                        {
                            Switch ((Local2 & 0x07))
                            {
                                Case (Zero)
                                {
                                    Local1 = Zero
                                }
                                Case (One)
                                {
                                    Local1 = One
                                }
                                Case (0x02)
                                {
                                    Local1 = 0x02
                                }
                                Case (0x04)
                                {
                                    Local1 = 0x03
                                }
                                Default
                                {
                                    Local1 = Zero
                                }

                            }
                        }
                        Else
                        {
                            Local1 = Zero
                        }

                        DerefOf (Local0 [0x02]) [Zero] = Local1
                    }
                    Else
                    {
                        DerefOf (Local0 [0x02]) [Zero] = 0xFF
                    }

                    DerefOf (Local0 [0x02]) [One] = 0xFF
                }
                Else
                {
                    DerefOf (Local0 [Zero]) [Zero] = 0x35
                }

                Return (Local0)
            }

            Method (SBCC, 4, Serialized)
            {
                Debug = "HP WMI Command 0x1F (BIOS Write)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        Zero, 
                        Buffer (0x04){}
                    }
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    If (((Arg0 == Zero) && (^^PCI0.SBRG.EC0.RA40 == One)))
                    {
                        Local1 = ^^PCI0.SBRG.EC0.R820 /* \_SB_.PCI0.SBRG.EC0_.R820 */
                        Local1 &= 0x03
                        If (((Local1 & 0x02) & (Arg1 == One)))
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0x36
                        }
                        ElseIf (((Local1 & One) & (Arg1 == 0x02)))
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0x36
                        }
                        ElseIf (((^^PCI0.SBRG.EC0.R403 == Zero) & (Arg1 == One)))
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0x35
                        }
                        Else
                        {
                            Local1 = ^^PCI0.SBRG.EC0.RA60 /* \_SB_.PCI0.SBRG.EC0_.RA60 */
                            If ((Arg1 == Zero))
                            {
                                Local1 &= 0xE0
                                ^^PCI0.SBRG.EC0.MBDC = Local1
                                Return (Local0)
                            }

                            If ((Arg1 == One))
                            {
                                Local1 &= 0xFFFFFFF9
                                Local1 |= 0x09
                            }

                            If ((Arg1 == 0x02))
                            {
                                Local1 &= 0xFFFFFFFA
                                Local1 |= 0x0A
                            }

                            ^^PCI0.SBRG.EC0.MBDC = Local1
                            Sleep (0x64)
                            Local1 = ^^PCI0.SBRG.EC0.RA60 /* \_SB_.PCI0.SBRG.EC0_.RA60 */
                            While (((Local1 & 0x10) != 0x10))
                            {
                                Sleep (0x64)
                                Local1 = ^^PCI0.SBRG.EC0.RA60 /* \_SB_.PCI0.SBRG.EC0_.RA60 */
                            }
                        }
                    }
                    ElseIf (((Arg0 == 0x63) && (^^PCI0.SBRG.EC0.R403 == One)))
                    {
                        Local1 = ^^PCI0.SBRG.EC0.RA60 /* \_SB_.PCI0.SBRG.EC0_.RA60 */
                        Local2 = Arg1
                        Switch (Local2)
                        {
                            Case (Zero)
                            {
                                Local1 &= 0xE0
                                ^^PCI0.SBRG.EC0.MBDC = Local1
                                Return (Local0)
                            }
                            Case (One)
                            {
                                Local1 &= 0xFFFFFFFA
                                Local1 |= 0x0A
                            }
                            Case (0x02)
                            {
                                Local1 &= 0xFFFFFFFC
                                Local1 |= 0x0C
                            }
                            Default
                            {
                                DerefOf (Local0 [0x02]) [Zero] = 0x35
                                Return (Local0)
                            }

                        }

                        ^^PCI0.SBRG.EC0.MBDC = Local1
                        Sleep (0x64)
                        Local1 = ^^PCI0.SBRG.EC0.RA60 /* \_SB_.PCI0.SBRG.EC0_.RA60 */
                        While (((Local1 & 0x10) != 0x10))
                        {
                            Sleep (0x64)
                            Local1 = ^^PCI0.SBRG.EC0.RA60 /* \_SB_.PCI0.SBRG.EC0_.RA60 */
                        }
                    }
                    Else
                    {
                        DerefOf (Local0 [0x02]) [Zero] = 0x34
                    }
                }
                Else
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x35
                }

                Return (Local0)
            }

            Method (GTDC, 1, NotSerialized)
            {
                WSMI (One, 0x28, 0x04, 0x80, Zero)
                Return (WFDA ())
            }

            Method (STDC, 3, NotSerialized)
            {
                WSMI (0x02, 0x28, 0x80, Zero, Zero)
                Return (WFDA ())
            }

            Method (GFCS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x29 (BIOS Read)"
                WSMI (One, 0x29, Zero, 0x04, Zero)
                Return (WFDA ())
            }

            Method (SFCS, 1, Serialized)
            {
                Debug = "HP WMI Command 0x29 (BIOS Write)"
                WSMI (0x02, 0x29, 0x04, Zero, Zero)
                Return (WFDA ())
            }

            Method (GPES, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x2A (BIOS Read)"
                WSMI (One, 0x2A, Zero, 0x04, Zero)
                Return (WFDA ())
            }

            Method (SPES, 1, Serialized)
            {
                Debug = "HP WMI Command 0x2A (BIOS Write)"
                WSMI (0x02, 0x2A, 0x04, Zero, Zero)
                Return (WFDA ())
            }

            Method (GBCO, 0, Serialized)
            {
                Debug = "HP WMI Command 0x2B (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    If (^^PCI0.SBRG.EC0.RA40)
                    {
                        If (^^PCI0.SBRG.EC0.R696)
                        {
                            If (^^PCI0.SBRG.EC0.R403)
                            {
                                Local2 = ^^PCI0.SBRG.EC0.R820 /* \_SB_.PCI0.SBRG.EC0_.R820 */
                                Local2 &= 0x03
                                Switch (Local2)
                                {
                                    Case (Zero)
                                    {
                                        Local1 = ^^PCI0.SBRG.EC0.R760 /* \_SB_.PCI0.SBRG.EC0_.R760 */
                                        If ((Local1 == 0xC5))
                                        {
                                            Local1 = 0x04
                                        }
                                        Else
                                        {
                                            Local1 = Zero
                                        }
                                    }
                                    Case (One)
                                    {
                                        Local1 = 0x02
                                    }
                                    Case (0x02)
                                    {
                                        Local2 = ^^PCI0.SBRG.EC0.R830 /* \_SB_.PCI0.SBRG.EC0_.R830 */
                                        If ((Local2 <= 0x0200))
                                        {
                                            Local1 = 0x03
                                        }
                                        ElseIf ((Local2 == Zero))
                                        {
                                            Local1 = Zero
                                        }
                                        Else
                                        {
                                            Local1 = One
                                        }
                                    }
                                    Default
                                    {
                                        DerefOf (Local0 [Zero]) [Zero] = 0x37
                                        Return (Local0)
                                    }

                                }
                            }
                            Else
                            {
                                Local1 = 0x02
                            }
                        }
                        Else
                        {
                            DerefOf (Local0 [Zero]) [Zero] = 0x37
                            Return (Local0)
                        }
                    }
                    Else
                    {
                        Local1 = 0xFF
                    }

                    If ((^^PCI0.SBRG.EC0.R4C0 == One))
                    {
                        Local1 = 0x06
                    }
                    ElseIf ((^^PCI0.SBRG.EC0.R610 == One))
                    {
                        Local1 = 0x05
                    }

                    DerefOf (Local0 [0x02]) [Zero] = Local1
                    DerefOf (Local0 [0x02]) [One] = 0xFF
                    Local2 = ^^PCI0.SBRG.EC0.RD70 /* \_SB_.PCI0.SBRG.EC0_.RD70 */
                    DerefOf (Local0 [0x02]) [0x02] = Local2
                }
                Else
                {
                    DerefOf (Local0 [Zero]) [Zero] = 0x35
                }

                Return (Local0)
            }

            Method (SBCO, 4, Serialized)
            {
                Debug = "HP WMI Command 0x2B (BIOS Write)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        Zero, 
                        Buffer (0x04){}
                    }
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    If ((Arg0 == Zero))
                    {
                        If (^^PCI0.SBRG.EC0.RA40)
                        {
                            If (^^PCI0.SBRG.EC0.R696)
                            {
                                Local1 = ^^PCI0.SBRG.EC0.R820 /* \_SB_.PCI0.SBRG.EC0_.R820 */
                                Switch (Arg1)
                                {
                                    Case (Zero)
                                    {
                                        Local1 = 0x40
                                    }
                                    Case (One)
                                    {
                                        If ((^^PCI0.SBRG.EC0.R403 == Zero))
                                        {
                                            DerefOf (Local0 [0x02]) [Zero] = 0x35
                                            Return (Local0)
                                        }

                                        Local1 = 0x41
                                    }
                                    Case (0x02)
                                    {
                                        If ((Local1 & One))
                                        {
                                            DerefOf (Local0 [0x02]) [Zero] = 0x36
                                            Return (Local0)
                                        }

                                        Local1 = 0x42
                                    }
                                    Case (0x03)
                                    {
                                        If ((^^PCI0.SBRG.EC0.R403 == Zero))
                                        {
                                            DerefOf (Local0 [0x02]) [Zero] = 0x35
                                            Return (Local0)
                                        }

                                        If (^^PCI0.SBRG.EC0.R8D0)
                                        {
                                            DerefOf (Local0 [0x02]) [Zero] = 0x35
                                            Return (Local0)
                                        }

                                        Local1 = 0x43
                                    }
                                    Case (0x04)
                                    {
                                        Local1 = 0x44
                                    }
                                    Case (0x05)
                                    {
                                        Local1 = 0x45
                                    }
                                    Case (0x06)
                                    {
                                        Local1 = 0x46
                                        ^^PCI0.SBRG.EC0.SHPM = One
                                    }
                                    Case (0x07)
                                    {
                                        Local1 = 0x47
                                        ^^PCI0.SBRG.EC0.STOE = One
                                    }
                                    Default
                                    {
                                        DerefOf (Local0 [0x02]) [Zero] = 0x03
                                        Return (Local0)
                                    }

                                }

                                ^^PCI0.SBRG.EC0.BDVO = Local1
                                Sleep (0x64)
                                Local1 = ^^PCI0.SBRG.EC0.R760 /* \_SB_.PCI0.SBRG.EC0_.R760 */
                                While (((Local1 & 0x80) != 0x80))
                                {
                                    Sleep (0x64)
                                    Local1 = ^^PCI0.SBRG.EC0.R760 /* \_SB_.PCI0.SBRG.EC0_.R760 */
                                }

                                Local1 &= 0x30
                                Switch (Local1)
                                {
                                    Case (Zero)
                                    {
                                        DerefOf (Local0 [0x02]) [Zero] = Zero
                                    }
                                    Case (0x10)
                                    {
                                        DerefOf (Local0 [0x02]) [Zero] = 0x35
                                    }
                                    Case (0x20)
                                    {
                                        DerefOf (Local0 [0x02]) [Zero] = 0x35
                                    }
                                    Case (0x30)
                                    {
                                        DerefOf (Local0 [0x02]) [Zero] = 0x37
                                    }

                                }
                            }
                            Else
                            {
                                DerefOf (Local0 [0x02]) [Zero] = 0x37
                            }
                        }
                        Else
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0x34
                        }
                    }
                    ElseIf ((Arg0 == One))
                    {
                        DerefOf (Local0 [0x02]) [Zero] = 0x34
                    }
                    Else
                    {
                        DerefOf (Local0 [0x02]) [Zero] = 0x03
                    }
                }
                Else
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x35
                }

                Return (Local0)
            }

            Method (GTCS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x2C (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00, 0x00, 0x00, 0x00                           // ....
                        }
                    }
                Return (Local0)
            }

            Method (STCS, 4, NotSerialized)
            {
                Debug = "HP WMI Command 0x2C (BIOS Write)"
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (GPSS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x31 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80){}
                    }
                Return (Local0)
            }

            Method (SPSS, 2, NotSerialized)
            {
                Debug = "HP WMI Command 0x31 (BIOS Write)"
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (GBKT, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x34 (BIOS Read)"
                WSMI (0x02, 0x34, Zero, 0x04, Zero)
                Return (WFDA ())
            }

            Method (SBKT, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x34 (BIOS Write)"
                WSMI (0x02, 0x34, 0x04, Zero, Zero)
                Return (WFDA ())
            }

            Method (GJGD, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x35 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00, 0x00, 0x00, 0x00                           // ....
                        }
                    }
                Return (Local0)
            }

            Method (SJGD, 4, NotSerialized)
            {
                Debug = "HP WMI Command 0x35 (BIOS Write)"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Return (Local0)
            }

            Method (GPST, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x36 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80)
                        {
                             0x00                                             // .
                        }
                    }
                Local1 = Zero
                DerefOf (Local0 [0x02]) [Local1] = 0x1D
                Local1++
                ^^PCI0.SBRG.EC0.PSIX = 0x9E
                Sleep (One)
                Local2 = ^^PCI0.SBRG.EC0.RD50 /* \_SB_.PCI0.SBRG.EC0_.RD50 */
                If (((Local2 & 0x08) == 0x08))
                {
                    WSMI (One, 0x36, Zero, 0x80, Zero)
                    Local1 = WBUF /* \WBUF */
                    Local2 = Zero
                    While ((Local2 < 0x80))
                    {
                        DerefOf (Local0 [0x02]) [Local2] = DerefOf (Local1 [
                            Local2])
                        Local2++
                    }

                    Local4 = SPST (Local1)
                }
                Else
                {
                    Local2 = Zero
                    While ((Local2 < 0x07))
                    {
                        Local3 = Zero
                        While ((Local3 < 0x02))
                        {
                            Local4 = ((Local2 * 0x04) + (Local3 + Zero))
                            Local4 += 0x80
                            ^^PCI0.SBRG.EC0.PSIX = Local4
                            Sleep (One)
                            Local4 = ^^PCI0.SBRG.EC0.RD40 /* \_SB_.PCI0.SBRG.EC0_.RD40 */
                            Local4 <<= 0x08
                            Local4 += ^^PCI0.SBRG.EC0.RD50 /* \_SB_.PCI0.SBRG.EC0_.RD50 */
                            If ((Local4 >= 0x05A0))
                            {
                                Local5 = 0xFF
                                Local6 = 0xFF
                            }
                            Else
                            {
                                If (((Local4 == Zero) && (Local3 == Zero)))
                                {
                                    ^^PCI0.SBRG.EC0.PSIX = (^^PCI0.SBRG.EC0.RDA0 + One)
                                    If (((^^PCI0.SBRG.EC0.RD40 == Zero) && (^^PCI0.SBRG.EC0.RD50 == Zero)))
                                    {
                                        DerefOf (Local0 [0x02]) [Local1] = 0xFF
                                        Local1++
                                        DerefOf (Local0 [0x02]) [Local1] = 0xFF
                                        Local1++
                                        DerefOf (Local0 [0x02]) [Local1] = 0xFF
                                        Local1++
                                        DerefOf (Local0 [0x02]) [Local1] = 0xFF
                                        Local1++
                                        Break
                                    }
                                }

                                Divide (Local4, 0x3C, Local6, Local5)
                                ToBCD (Local5, Local5)
                                ToBCD (Local6, Local6)
                            }

                            DerefOf (Local0 [0x02]) [Local1] = Local5
                            Local1++
                            DerefOf (Local0 [0x02]) [Local1] = Local6
                            Local1++
                            Local3++
                        }

                        Local2++
                    }
                }

                Return (Local0)
            }

            Method (SPST, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x36 (BIOS Write)"
                WSMI (0x02, 0x36, 0x80, Zero, Zero)
                Name (BCBF, Buffer (0x1C)
                {
                     0x00                                             // .
                })
                Name (PSBF, Buffer (0x1C)
                {
                     0x00                                             // .
                })
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = Zero
                If ((DerefOf (Arg0 [Local1]) != 0x1D))
                {
                    Local0 [Zero] = 0x06
                    Return (Local0)
                }

                Local2 = Zero
                While ((Local2 < 0x07))
                {
                    Local4 = ((Local2 * 0x04) + 0x02)
                    Local4 += 0x80
                    ^^PCI0.SBRG.EC0.PSIX = Local4
                    Sleep (One)
                    BCBF [((Local2 * 0x04) + Zero)] = ^^PCI0.SBRG.EC0.RD50 /* \_SB_.PCI0.SBRG.EC0_.RD50 */
                    BCBF [((Local2 * 0x04) + One)] = ^^PCI0.SBRG.EC0.RD40 /* \_SB_.PCI0.SBRG.EC0_.RD40 */
                    Local4++
                    ^^PCI0.SBRG.EC0.PSIX = Local4
                    Sleep (One)
                    BCBF [((Local2 * 0x04) + 0x02)] = ^^PCI0.SBRG.EC0.RD50 /* \_SB_.PCI0.SBRG.EC0_.RD50 */
                    BCBF [((Local2 * 0x04) + 0x03)] = ^^PCI0.SBRG.EC0.RD40 /* \_SB_.PCI0.SBRG.EC0_.RD40 */
                    Local2++
                }

                Local1 = One
                While ((Local1 < 0x1C))
                {
                    Divide ((Local1 - One), 0x04, Local3, Local2)
                    Local4 = DerefOf (Arg0 [Local1])
                    Local1++
                    Local5 = DerefOf (Arg0 [Local1])
                    Local1++
                    If (((Local4 == 0xFF) && (Local5 == 0xFF)))
                    {
                        Local6 = 0xFFFF
                    }
                    Else
                    {
                        FromBCD (Local4, Local4)
                        FromBCD (Local5, Local5)
                        If (((Local4 > 0x17) || (Local5 > 0x3B)))
                        {
                            Local0 [Zero] = 0x06
                            Return (Local0)
                        }

                        Local6 = ((Local4 * 0x3C) + Local5)
                        Local4 = DerefOf (BCBF [((Local2 * 0x04) + Zero)]
                            )
                        Local4 += (DerefOf (BCBF [((Local2 * 0x04) + One
                            )]) << 0x08)
                        Local5 = DerefOf (BCBF [((Local2 * 0x04) + 0x02)]
                            )
                        Local5 += (DerefOf (BCBF [((Local2 * 0x04) + 0x03
                            )]) << 0x08)
                        If (((Local6 >= Local4) && (Local6 <= Local5)))
                        {
                            Local0 [Zero] = 0x39
                            Return (Local0)
                        }
                    }

                    PSBF [((Local2 * 0x04) + (Local3 + Zero)
                        )] = (Local6 & 0xFF)
                    PSBF [((Local2 * 0x04) + (Local3 + One)
                        )] = ((Local6 >> 0x08) & 0xFF)
                    If ((Local3 == Zero))
                    {
                        Local7 = Local6
                    }
                    ElseIf (((((Local6 != 0xFFFF) && (Local7 != 
                        0xFFFF)) && (Local6 <= Local7)) || (((Local6 == 0xFFFF) && (Local7 != 
                        0xFFFF)) || ((Local6 != 0xFFFF) && (Local7 == 0xFFFF)))))
                    {
                        Local0 [Zero] = 0x06
                        Return (Local0)
                    }
                }

                Local1 = Zero
                While ((Local1 < SizeOf (PSBF)))
                {
                    Local2 = DerefOf (PSBF [Local1])
                    If ((Local2 != 0xFF))
                    {
                        Break
                    }

                    Local1++
                    If ((Local1 == SizeOf (PSBF)))
                    {
                        ^^PCI0.SBRG.EC0.PSDL = Zero
                        ^^PCI0.SBRG.EC0.PSDH = Zero
                        ^^PCI0.SBRG.EC0.PSIX = 0x1E
                        Sleep (One)
                        Local1 = Buffer (0x80)
                            {
                                 0xFF                                             // .
                            }
                        SBCT (Local1)
                        SBST (0xFF, 0xFF, 0xFF, 0xFF)
                        Return (Local0)
                    }
                }

                Local1 = Zero
                While ((Local1 < SizeOf (PSBF)))
                {
                    Local2 = Local1
                    ^^PCI0.SBRG.EC0.PSDL = DerefOf (PSBF [Local1])
                    Local1++
                    ^^PCI0.SBRG.EC0.PSDH = DerefOf (PSBF [Local1])
                    Local1++
                    Divide (Local2, 0x04, Local3, Local2)
                    Local2 = (Local2 * 0x04)
                    If (Local3)
                    {
                        Local2 += One
                    }
                    Else
                    {
                        Local2 += Zero
                    }

                    ^^PCI0.SBRG.EC0.PSIX = Local2
                    Sleep (One)
                }

                ^^PCI0.SBRG.EC0.PSDL = One
                ^^PCI0.SBRG.EC0.PSDH = Zero
                ^^PCI0.SBRG.EC0.PSIX = 0x1E
                Sleep (One)
                Return (Local0)
            }

            Method (GBCT, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x37 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80)
                        {
                             0x00                                             // .
                        }
                    }
                Local1 = Zero
                DerefOf (Local0 [0x02]) [Local1] = 0x1D
                Local1++
                ^^PCI0.SBRG.EC0.PSIX = 0x9E
                Sleep (One)
                Local2 = ^^PCI0.SBRG.EC0.RD50 /* \_SB_.PCI0.SBRG.EC0_.RD50 */
                If (((Local2 & 0x08) == 0x08))
                {
                    WSMI (One, 0x37, Zero, 0x80, Zero)
                    Local1 = WBUF /* \WBUF */
                    Local2 = Zero
                    While ((Local2 < 0x80))
                    {
                        DerefOf (Local0 [0x02]) [Local2] = DerefOf (Local1 [
                            Local2])
                        Local2++
                    }

                    Local4 = SBCT (Local1)
                }
                Else
                {
                    Local2 = Zero
                    While ((Local2 < 0x07))
                    {
                        Local3 = Zero
                        While ((Local3 < 0x02))
                        {
                            Local4 = ((Local2 * 0x04) + (Local3 + 0x02))
                            Local4 += 0x80
                            ^^PCI0.SBRG.EC0.PSIX = Local4
                            Sleep (One)
                            Local4 = ^^PCI0.SBRG.EC0.RD40 /* \_SB_.PCI0.SBRG.EC0_.RD40 */
                            Local4 <<= 0x08
                            Local4 += ^^PCI0.SBRG.EC0.RD50 /* \_SB_.PCI0.SBRG.EC0_.RD50 */
                            If ((Local4 >= 0x05A0))
                            {
                                Local5 = 0xFF
                                Local6 = 0xFF
                            }
                            Else
                            {
                                If (((Local4 == Zero) && (Local3 == Zero)))
                                {
                                    ^^PCI0.SBRG.EC0.PSIX = (^^PCI0.SBRG.EC0.RDA0 + One)
                                    Sleep (One)
                                    If (((^^PCI0.SBRG.EC0.RD40 == Zero) && (^^PCI0.SBRG.EC0.RD50 == Zero)))
                                    {
                                        DerefOf (Local0 [0x02]) [Local1] = 0xFF
                                        Local1++
                                        DerefOf (Local0 [0x02]) [Local1] = 0xFF
                                        Local1++
                                        DerefOf (Local0 [0x02]) [Local1] = 0xFF
                                        Local1++
                                        DerefOf (Local0 [0x02]) [Local1] = 0xFF
                                        Local1++
                                        Break
                                    }
                                }

                                Divide (Local4, 0x3C, Local6, Local5)
                                ToBCD (Local5, Local5)
                                ToBCD (Local6, Local6)
                            }

                            DerefOf (Local0 [0x02]) [Local1] = Local5
                            Local1++
                            DerefOf (Local0 [0x02]) [Local1] = Local6
                            Local1++
                            Local3++
                        }

                        Local2++
                    }
                }

                Return (Local0)
            }

            Method (SBCT, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x37 (BIOS Write)"
                WSMI (0x02, 0x37, 0x80, Zero, Zero)
                Name (BCBF, Buffer (0x1C)
                {
                     0x00                                             // .
                })
                Name (PSBF, Buffer (0x1C)
                {
                     0x00                                             // .
                })
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = Zero
                If ((DerefOf (Arg0 [Local1]) != 0x1D))
                {
                    Local0 [Zero] = 0x06
                    Return (Local0)
                }

                Local2 = Zero
                While ((Local2 < 0x07))
                {
                    Local4 = ((Local2 * 0x04) + Zero)
                    Local4 += 0x80
                    ^^PCI0.SBRG.EC0.PSIX = Local4
                    Sleep (One)
                    PSBF [((Local2 * 0x04) + Zero)] = ^^PCI0.SBRG.EC0.RD50 /* \_SB_.PCI0.SBRG.EC0_.RD50 */
                    PSBF [((Local2 * 0x04) + One)] = ^^PCI0.SBRG.EC0.RD40 /* \_SB_.PCI0.SBRG.EC0_.RD40 */
                    Local4++
                    ^^PCI0.SBRG.EC0.PSIX = Local4
                    Sleep (One)
                    PSBF [((Local2 * 0x04) + 0x02)] = ^^PCI0.SBRG.EC0.RD50 /* \_SB_.PCI0.SBRG.EC0_.RD50 */
                    PSBF [((Local2 * 0x04) + 0x03)] = ^^PCI0.SBRG.EC0.RD40 /* \_SB_.PCI0.SBRG.EC0_.RD40 */
                    Local2++
                }

                Local1 = One
                While ((Local1 < 0x1C))
                {
                    Divide ((Local1 - One), 0x04, Local3, Local2)
                    Local4 = DerefOf (Arg0 [Local1])
                    Local1++
                    Local5 = DerefOf (Arg0 [Local1])
                    Local1++
                    If (((Local4 == 0xFF) && (Local5 == 0xFF)))
                    {
                        Local6 = 0xFFFF
                    }
                    Else
                    {
                        FromBCD (Local4, Local4)
                        FromBCD (Local5, Local5)
                        If (((Local4 > 0x17) || (Local5 > 0x3B)))
                        {
                            Local0 [Zero] = 0x06
                            Return (Local0)
                        }

                        Local6 = ((Local4 * 0x3C) + Local5)
                        Local4 = DerefOf (PSBF [((Local2 * 0x04) + Zero)]
                            )
                        Local4 += (DerefOf (PSBF [((Local2 * 0x04) + One
                            )]) << 0x08)
                        Local5 = DerefOf (PSBF [((Local2 * 0x04) + 0x02)]
                            )
                        Local5 += (DerefOf (PSBF [((Local2 * 0x04) + 0x03
                            )]) << 0x08)
                        If (((Local6 >= Local4) && (Local6 <= Local5)))
                        {
                            Local0 [Zero] = 0x39
                            Return (Local0)
                        }
                    }

                    BCBF [((Local2 * 0x04) + (Local3 + Zero)
                        )] = (Local6 & 0xFF)
                    BCBF [((Local2 * 0x04) + (Local3 + One)
                        )] = ((Local6 >> 0x08) & 0xFF)
                    If ((Local3 == Zero))
                    {
                        Local7 = Local6
                    }
                    ElseIf (((((Local6 != 0xFFFF) && (Local7 != 
                        0xFFFF)) && (Local6 <= Local7)) || (((Local6 == 0xFFFF) && (Local7 != 
                        0xFFFF)) || ((Local6 != 0xFFFF) && (Local7 == 0xFFFF)))))
                    {
                        Local0 [Zero] = 0x06
                        Return (Local0)
                    }
                }

                Local1 = Zero
                While ((Local1 < SizeOf (PSBF)))
                {
                    Local2 = DerefOf (PSBF [Local1])
                    If ((Local2 != 0xFF))
                    {
                        Break
                    }

                    Local1++
                    If ((Local1 == SizeOf (PSBF)))
                    {
                        ^^PCI0.SBRG.EC0.PSDL = Zero
                        ^^PCI0.SBRG.EC0.PSDH = Zero
                        ^^PCI0.SBRG.EC0.PSIX = 0x1E
                        Sleep (One)
                        Return (Local0)
                    }
                }

                Local1 = Zero
                While ((Local1 < SizeOf (BCBF)))
                {
                    Local2 = Local1
                    ^^PCI0.SBRG.EC0.PSDL = DerefOf (BCBF [Local1])
                    Local1++
                    ^^PCI0.SBRG.EC0.PSDH = DerefOf (BCBF [Local1])
                    Local1++
                    Divide (Local2, 0x04, Local3, Local2)
                    Local2 = (Local2 * 0x04)
                    If (Local3)
                    {
                        Local2 += 0x03
                    }
                    Else
                    {
                        Local2 += 0x02
                    }

                    ^^PCI0.SBRG.EC0.PSIX = Local2
                    Sleep (One)
                }

                ^^PCI0.SBRG.EC0.PSDL = One
                ^^PCI0.SBRG.EC0.PSDH = Zero
                ^^PCI0.SBRG.EC0.PSIX = 0x1E
                Sleep (One)
                Return (Local0)
            }

            Method (GBST, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x38 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00, 0x00, 0x00, 0x00                           // ....
                        }
                    }
                ^^PCI0.SBRG.EC0.PSIX = 0x9E
                Sleep (One)
                Local2 = ^^PCI0.SBRG.EC0.RD50 /* \_SB_.PCI0.SBRG.EC0_.RD50 */
                If (((Local2 & 0x08) == 0x08))
                {
                    WSMI (One, 0x38, Zero, 0x04, Zero)
                    Local1 = WBUF /* \WBUF */
                    Local2 = Zero
                    While ((Local2 < 0x04))
                    {
                        DerefOf (Local0 [0x02]) [Local2] = DerefOf (Local1 [
                            Local2])
                        Local2++
                    }

                    Local4 = SBST (DerefOf (Local1 [Zero]), Zero, Zero, Zero)
                }
                Else
                {
                    ^^PCI0.SBRG.EC0.PSIX = 0x9F
                    Sleep (One)
                    DerefOf (Local0 [0x02]) [Zero] = ^^PCI0.SBRG.EC0.RD50 /* \_SB_.PCI0.SBRG.EC0_.RD50 */
                }

                Return (Local0)
            }

            Method (SBST, 4, NotSerialized)
            {
                Debug = "HP WMI Command 0x38 (BIOS Write)"
                WSMI (0x02, 0x38, 0x04, Zero, Zero)
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                If ((((Arg0 >= 0x0A) && (Arg0 <= 0x63)) || (
                    Arg0 == 0xFF)))
                {
                    ^^PCI0.SBRG.EC0.PSDH = Zero
                    ^^PCI0.SBRG.EC0.PSDL = Arg0
                    ^^PCI0.SBRG.EC0.PSIX = 0x1F
                    Sleep (One)
                }
                Else
                {
                    Local0 [Zero] = 0x06
                }

                Return (Local0)
            }

            Method (GPPS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x3E (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0xFA, 0x64, 0x00, 0x00                           // .d..
                        }
                    }
                Return (Local0)
            }

            Method (SPPS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x3E (BIOS Write)"
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local3 = DerefOf (Local1 [One])
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (GBMF, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x44 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00, 0x00, 0x00, 0x00                           // ....
                        }
                    }
                If ((^^PCI0.SBRG.EC0.R694 || ^^PCI0.SBRG.EC0.R695))
                {
                    Local1 = One
                }
                Else
                {
                    Local1 = Zero
                }

                DerefOf (Local0 [0x02]) [Zero] = Local1
                Return (Local0)
            }

            Method (RHPM, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x4B (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80)
                        {
                             0x00                                             // .
                        }
                    }
                DerefOf (Local0 [0x02]) [Zero] = 0x64
                DerefOf (Local0 [0x02]) [One] = 0x32
                DerefOf (Local0 [0x02]) [0x02] = One
                Return (Local0)
            }

            Method (WHPM, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x4B (BIOS Write)"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = One
                Local2 = DerefOf (Arg0 [Local1])
                If (((Local2 > 0x64) || (Local2 < 0x0A)))
                {
                    Local0 [Zero] = 0x51
                    Return (Local0)
                }

                Local1 = 0x02
                Local3 = DerefOf (Arg0 [Local1])
                If (((Local3 > 0x64) || (Local3 < 0x0A)))
                {
                    Local0 [Zero] = 0x52
                    Return (Local0)
                }

                If ((Local2 < Local3))
                {
                    Local0 [Zero] = 0x53
                    Return (Local0)
                }

                Local1 = 0x03
                Local3 = DerefOf (Arg0 [Local1])
                If ((Local3 > One))
                {
                    Local0 [Zero] = 0x54
                    Return (Local0)
                }

                Return (Local0)
            }

            Name (WTPS, One)
            Method (GTPS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x4C (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00, 0x00, 0x00, 0x00                           // ....
                        }
                    }
                DerefOf (Local0 [0x02]) [Zero] = WTPS /* \_SB_.WMID.WTPS */
                Return (Local0)
            }

            Method (STPS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x4C (BIOS Write)"
                Local0 = WBUF /* \WBUF */
                If ((DerefOf (Local0 [Zero]) != WTPS))
                {
                    If ((DerefOf (Local0 [Zero]) == 0x05)){}
                    Else
                    {
                    }

                    WTPS = DerefOf (Local0 [Zero])
                    ^^WMPS.EVTY = One
                    Notify (WMPS, 0x80) // Status Change
                }

                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (GPCS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x4D (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00, 0x00, 0x00, 0x00                           // ....
                        }
                    }
                Return (Local0)
            }

            Method (SPCS, 4, NotSerialized)
            {
                Debug = "HP WMI Command 0x4D (BIOS Write)"
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local3 = DerefOf (Local1 [One])
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (GATC, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x51 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00, 0x00, 0x00, 0x00                           // ....
                        }
                    }
                DerefOf (Local0 [0x02]) [Zero] = Zero
                Return (Local0)
            }

            Method (SATC, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x51 (BIOS Write)"
                Local0 = WBUF /* \WBUF */
                Local1 = DerefOf (Local0 [Zero])
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (CSTA, 0, NotSerialized)
            {
                WSMI (0x00020002, One, Zero, 0x04, One)
                Return (WFDA ())
            }

            Method (CACT, 0, NotSerialized)
            {
                WSMI (0x00020002, 0x02, 0x04, Zero, One)
                Return (WFDA ())
            }

            Method (CDAC, 0, NotSerialized)
            {
                WSMI (0x00020002, 0x03, 0x04, Zero, One)
                Return (WFDA ())
            }

            Method (CAIP, 0, NotSerialized)
            {
                WSMI (0x00020002, 0x06, 0x80, Zero, One)
                Return (WFDA ())
            }

            Method (GDSS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x52 (BIOS Read)"
                WSMI (One, 0x52, Zero, 0x04, Zero)
                Return (WFDA ())
            }

            Method (SDSS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x52 (BIOS Write)"
                WSMI (0x02, 0x52, 0x04, Zero, Zero)
                Return (WFDA ())
            }

            Method (RCLS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x53 (BIOS Read)"
                WSMI (One, 0x53, One, 0x0400, Zero)
                Return (WFDA ())
            }

            Method (WCLS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x53 (BIOS Write)"
                WSMI (0x02, 0x53, 0x0400, Zero, Zero)
                Return (WFDA ())
            }

            Method (GABD, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x56 (BIOS Read)"
                WSMI (One, 0x56, One, 0x80, Zero)
                If ((ADBE == One))
                {
                    If (^^PCI0.SBRG.EC0.ECON)
                    {
                        CM6C = 0x61
                        Sleep (0x0A)
                        DT68 = 0x04
                        Sleep (0x0A)
                        Local1 = Zero
                        While ((Local1 <= 0x05))
                        {
                            If ((^^PCI0.SBRG.EC0.GBCS == 0xA5))
                            {
                                Break
                            }

                            Sleep (0x0A)
                            Local1++
                        }
                    }
                }

                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80)
                        {
                             0x00                                             // .
                        }
                    }
                Name (EXBT, Buffer (0x80){})
                EXBT = ^^PCI0.SBRG.EC0.GBCE /* \_SB_.PCI0.SBRG.EC0_.GBCE */
                Local1 = Zero
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    While ((Local1 <= 0x1C))
                    {
                        DerefOf (Local0 [0x02]) [Local1] = DerefOf (EXBT [
                            Local1])
                        Local1++
                    }

                    ^^PCI0.SBRG.EC0.GBCS = Zero
                }

                Return (Local0)
            }

            Method (RBCT, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x58 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80)
                        {
                             0x00                                             // .
                        }
                    }
                Local1 = Zero
                DerefOf (Local0 [0x02]) [Local1] = 0x1D
                Return (Local0)
            }

            Method (WBCT, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x58 (BIOS Write)"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = Zero
                If (((DerefOf (Arg0 [Local1]) != 0x1D) || (
                    DerefOf (Arg0 [Local1]) != 0x39)))
                {
                    Local0 [Zero] = 0x06
                }

                Return (Local0)
            }

            Method (GSCM, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x5A (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00                                             // .
                        }
                    }
                Return (Local0)
            }

            Method (SSCM, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x5A (BIOS Write)"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Local0)
            }

            Method (GDDS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x5C (BIOS Read)"
                WSMI (One, 0x5C, One, 0x80, Zero)
                Return (WFDA ())
            }

            Method (SOPC, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x5C (BIOS Write)"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = Zero
                Local2 = DerefOf (Arg0 [Local1])
                If ((Local2 == One)){}
                If ((Local2 == 0x02)){}
                If ((Local2 == 0x03)){}
                Return (Local0)
            }

            Method (GMLS, 0, NotSerialized)
            {
                Debug = "HP WMI Command 0x61 (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00                                             // .
                        }
                    }
                Return (Local0)
            }

            Method (SMLS, 1, NotSerialized)
            {
                Debug = "HP WMI Command 0x61 (BIOS Write)"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = Zero
                Local2 = DerefOf (Arg0 [Local1])
                Return (Local0)
            }

            Method (GBSC, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x03 for WMI 20000h command"
                Local0 = Zero
                Local1 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80){}
                    }
                DerefOf (Local1 [0x02]) [Zero] = Local0
                Return (Local1)
            }

            Method (GASC, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x1E for WMI 20000h command"
                Local0 = Zero
                Local1 = Zero
                Local2 = Zero
                Local3 = Zero
                Local0 |= 0x80
                Local1 |= 0x04
                Local4 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80){}
                    }
                DerefOf (Local4 [0x02]) [Zero] = Local0
                DerefOf (Local4 [0x02]) [One] = Local1
                DerefOf (Local4 [0x02]) [0x02] = Local2
                DerefOf (Local4 [0x02]) [0x03] = Local3
                Return (Local4)
            }

            Method (ACPD, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x01 for 0x2000B (BIOS Read)"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80){}
                    }
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    Local1 = Zero
                    Local1 = (^^PCI0.SBRG.EC0.R4F0 & 0x0F)
                    DerefOf (Local0 [0x02]) [Zero] = Local1
                    DerefOf (Local0 [0x02]) [One] = Zero
                }
                Else
                {
                    Local0 [Zero] = 0x50
                }

                Return (Local0)
            }

            Method (GM01, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x01 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                DerefOf (Local0 [0x02]) [Zero] = Zero
                DerefOf (Local0 [0x02]) [One] = Zero
                Return (Local0)
            }

            Method (GM02, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x02 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                DerefOf (Local0 [0x02]) [Zero] = Zero
                DerefOf (Local0 [0x02]) [One] = Zero
                DerefOf (Local0 [0x02]) [0x02] = Zero
                Return (Local0)
            }

            Method (GM03, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x03 for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local3 = DerefOf (Local1 [One])
                Local4 = DerefOf (Local1 [0x02])
                Return (Local0)
            }

            Method (GM04, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x04 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                DerefOf (Local0 [0x02]) [Zero] = Zero
                DerefOf (Local0 [0x02]) [One] = Zero
                DerefOf (Local0 [0x02]) [0x02] = Zero
                Return (Local0)
            }

            Method (GM05, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x05 for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local3 = DerefOf (Local1 [One])
                Local4 = DerefOf (Local1 [0x02])
                Local5 = DerefOf (Local1 [0x03])
                Return (Local0)
            }

            Method (GM06, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x06 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                DerefOf (Local0 [0x02]) [Zero] = Zero
                Return (Local0)
            }

            Method (GM07, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x07 for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Local0)
            }

            Method (GM08, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x08 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                DerefOf (Local0 [0x02]) [Zero] = Zero
                DerefOf (Local0 [0x02]) [One] = Zero
                Return (Local0)
            }

            Method (GM09, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x09 for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local3 = DerefOf (Local1 [One])
                Return (Local0)
            }

            Method (GM0A, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x0A for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                DerefOf (Local0 [0x02]) [Zero] = Zero
                Return (Local0)
            }

            Method (GM0B, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x0B for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Local0)
            }

            Method (GM0C, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x0C for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x1000, 
                        Buffer (0x1000){}
                    }
                DerefOf (Local0 [0x02]) [Zero] = Zero
                Return (Local0)
            }

            Method (GM0D, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x0D for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = GMBF /* \GMBF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Local0)
            }

            Method (GM0E, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x0E for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local3 = DerefOf (Local1 [0x02])
                Return (Local0)
            }

            Method (GM0F, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x0F for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = GMBF /* \GMBF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Local0)
            }

            Method (GM10, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x10 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                Local1 = WBUF /* \WBUF */
                DerefOf (Local0 [0x02]) [Zero] = 0x02
                ^^PCI0.SBRG.EC0.OMCC = One
                Return (Local0)
            }

            Method (GM11, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x11 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                DerefOf (Local0 [0x02]) [Zero] = Zero
                DerefOf (Local0 [0x02]) [One] = Zero
                DerefOf (Local0 [0x02]) [0x02] = Zero
                If ((Local2 == Zero))
                {
                    DerefOf (Local0 [0x02]) [Zero] = ^^PCI0.SBRG.EC0.FMR1 /* \_SB_.PCI0.SBRG.EC0_.FMR1 */
                    DerefOf (Local0 [0x02]) [One] = ^^PCI0.SBRG.EC0.FSUS /* \_SB_.PCI0.SBRG.EC0_.FSUS */
                    DerefOf (Local0 [0x02]) [0x02] = ^^PCI0.SBRG.EC0.FS1H /* \_SB_.PCI0.SBRG.EC0_.FS1H */
                    DerefOf (Local0 [0x02]) [0x03] = ^^PCI0.SBRG.EC0.FS1L /* \_SB_.PCI0.SBRG.EC0_.FS1L */
                }
                Else
                {
                    DerefOf (Local0 [0x02]) [Zero] = ^^PCI0.SBRG.EC0.FMR2 /* \_SB_.PCI0.SBRG.EC0_.FMR2 */
                    DerefOf (Local0 [0x02]) [One] = ^^PCI0.SBRG.EC0.FSUS /* \_SB_.PCI0.SBRG.EC0_.FSUS */
                    DerefOf (Local0 [0x02]) [0x02] = ^^PCI0.SBRG.EC0.FS2H /* \_SB_.PCI0.SBRG.EC0_.FS2H */
                    DerefOf (Local0 [0x02]) [0x03] = ^^PCI0.SBRG.EC0.FS2L /* \_SB_.PCI0.SBRG.EC0_.FS2L */
                }

                Return (Local0)
            }

            Method (GM12, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x12 for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local3 = DerefOf (Local1 [One])
                Return (Local0)
            }

            Method (GM13, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x13 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x1B, 
                        Buffer (0x1B){}
                    }
                Local1 = WBUF /* \WBUF */
                DerefOf (Local0 [0x02]) [Zero] = Zero
                DerefOf (Local0 [0x02]) [One] = Zero
                DerefOf (Local0 [0x02]) [0x02] = Zero
                Return (Local0)
            }

            Method (GM14, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x14 for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local3 = DerefOf (Local1 [One])
                Local4 = DerefOf (Local1 [0x02])
                Return (Local0)
            }

            Method (GM15, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x15 for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Local0)
            }

            Method (GM16, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x16 for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = Zero
                Local3 = DerefOf (Local1 [Zero])
                Local2 |= Local3
                Local3 = DerefOf (Local1 [One])
                Local2 |= (Local3 << 0x08)
                Local3 = DerefOf (Local1 [0x02])
                Local2 |= (Local3 << 0x10)
                Local3 = DerefOf (Local1 [0x03])
                Local2 |= (Local3 << 0x18)
                Local4 = Local2
                Return (Local0)
            }

            Method (GM17, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x17 for WMI 20008h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Local0)
            }

            Method (GM18, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x18 for WMI 20008h command"
                WSMI (0x00020008, 0x18, Zero, 0x80, Zero)
                Return (WFDA ())
            }

            Method (GM19, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x19 for WMI 20008h command"
                WSMI (0x00020008, 0x19, 0x80, Zero, Zero)
                Return (WFDA ())
            }

            Method (GM1A, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x1A for WMI 20008h command"
                Local0 = Package (0x04)
                    {
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local3 = DerefOf (Local1 [One])
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    ^^PCI0.SBRG.EC0.HPCM = Local3
                    CMSW (0xE6, Local3)
                }
                Else
                {
                    ^^PCI0.SBRG.EC0.HPCM = Zero
                }

                Local3 = DerefOf (Local1 [0x02])
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    ^^PCI0.SBRG.EC0.FAMC = Local3
                }

                Return (Local0)
            }

            Method (GM1B, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x1B for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                Local1 = WBUF /* \WBUF */
                DerefOf (Local0 [0x02]) [Zero] = Zero
                DerefOf (Local0 [0x02]) [One] = Zero
                Return (Local0)
            }

            Method (GM1C, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x1C for WMI 20008h command"
                Local0 = Package (0x04)
                    {
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local3 = DerefOf (Local1 [One])
                Return (Local0)
            }

            Method (GM1D, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x1D for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                Local1 = WBUF /* \WBUF */
                DerefOf (Local0 [0x02]) [Zero] = Zero
                Return (Local0)
            }

            Method (GM1E, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x1E for WMI 20008h command"
                Local0 = Package (0x04)
                    {
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Local0)
            }

            Method (GM1F, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x1F for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                Local1 = WBUF /* \WBUF */
                DerefOf (Local0 [0x02]) [Zero] = Zero
                Return (Local0)
            }

            Method (GM20, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x20 for WMI 20008h command"
                Local0 = Package (0x04)
                    {
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Local0)
            }

            Method (GM21, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x21 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                If (CondRefOf (\_SB.PCI0.GPP9.SWUS.SWDS.VGA))
                {
                    DerefOf (Local0 [0x02]) [Zero] = Zero
                }
                ElseIf (CondRefOf (\_SB.PCI0.GPP9.PEGP))
                {
                    DerefOf (Local0 [0x02]) [Zero] = CTGP /* \_SB_.WMID.CTGP */
                    If ((^^NPCF.DBAC == One))
                    {
                        DerefOf (Local0 [0x02]) [One] = Zero
                    }
                    Else
                    {
                        DerefOf (Local0 [0x02]) [One] = One
                    }

                    If ((^^PCI0.SBRG.EC0.ECON == One))
                    {
                        Local1 = (^^PCI0.SBRG.EC0.R910 & 0x0F)
                        Sleep (0x14)
                        DerefOf (Local0 [0x02]) [0x02] = Local1
                    }

                    DerefOf (Local0 [0x02]) [0x03] = ^^PCI0.GPP9.PEGP.GPST /* External reference */
                }
                Else
                {
                    DerefOf (Local0 [0x02]) [Zero] = Zero
                }

                Return (Local0)
            }

            Name (TNVD, Zero)
            Method (GM22, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x20 for WMI 20008h command"
                Local0 = Package (0x04)
                    {
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                If (CondRefOf (\_SB.PCI0.GPP0.SWUS.SWDS.VGA))
                {
                    Local2 = DerefOf (Local1 [Zero])
                }
                ElseIf (CondRefOf (\_SB.PCI0.GPP9.PEGP))
                {
                    CTGP = DerefOf (Local1 [Zero])
                    If ((DerefOf (Local1 [One]) == Zero))
                    {
                        ^^NPCF.DBAC = One
                    }
                    Else
                    {
                        ^^NPCF.DBAC = Zero
                    }

                    Sleep (0x64)
                    Notify (NPCF, 0xC0) // Hardware-Specific
                    If ((NVDE == One))
                    {
                        Local2 = (DerefOf (Local1 [0x02]) | 0xD0)
                        Sleep (0x14)
                        If ((^^PCI0.SBRG.EC0.RDE0 < 0xD2))
                        {
                            If ((Local2 <= 0xD2))
                            {
                                If ((^^PCI0.GPP9.GSTA () == One))
                                {
                                    Notify (^^PCI0.GPP9.PEGP, Local2)
                                    ^^PCI0.SBRG.EC0.NVDO = Local2
                                }
                                Else
                                {
                                    TNVD = Local2
                                }
                            }
                        }
                    }

                    If ((NVDE == One))
                    {
                        ^^PCI0.GPP9.PEGP.GPST = DerefOf (Local1 [0x03])
                        If ((^^PCI0.GPP9.GSTA () == One))
                        {
                            Notify (^^PCI0.GPP9.PEGP, 0xC0) // Hardware-Specific
                        }
                    }
                }
                Else
                {
                    Local2 = DerefOf (Local1 [Zero])
                }

                Return (Local0)
            }

            Method (GM23, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x23 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                Local1 = WBUF /* \WBUF */
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    DerefOf (Local0 [0x02]) [Zero] = ^^PCI0.SBRG.EC0.R480 /* \_SB_.PCI0.SBRG.EC0_.R480 */
                }

                Return (Local0)
            }

            Method (GM24, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x23 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                DerefOf (Local0 [0x02]) [Zero] = Zero
                Return (Local0)
            }

            Method (GM25, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x25 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                Local1 = WBUF /* \WBUF */
                Local1 = DerefOf (Local1 [Zero])
                Return (Local0)
            }

            Method (GM26, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x26 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    DerefOf (Local0 [0x02]) [Zero] = ^^PCI0.SBRG.EC0.REC2 /* \_SB_.PCI0.SBRG.EC0_.REC2 */
                }

                Return (Local0)
            }

            Method (GM27, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x27 for WMI 20008h command"
                Local0 = Package (0x04)
                    {
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                HMFM = DerefOf (Local1 [Zero])
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    ^^PCI0.SBRG.EC0.FFFS = HMFM /* \_SB_.WMID.HMFM */
                }

                Return (Local0)
            }

            Method (GM28, 0, Serialized)
            {
                Debug = "HP WMI Command type 0x28 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x40, 
                        Buffer (0x40){}
                    }
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    Switch (^^PCI0.SBRG.EC0.REA0)
                    {
                        Case (One)
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0x28
                        }
                        Case (0x02)
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0x41
                        }
                        Case (0x03)
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0x5A
                        }
                        Case (0x04)
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0x78
                        }
                        Case (0x05)
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0x8C
                        }
                        Case (0x06)
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0x96
                        }
                        Case (0x07)
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0xB4
                        }
                        Case (0x08)
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0xC8
                        }
                        Case (0x09)
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0xE6
                        }
                        Case (0x0A)
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0x4A
                            DerefOf (Local0 [0x02]) [One] = One
                        }
                        Default
                        {
                            DerefOf (Local0 [0x02]) [Zero] = 0xE6
                        }

                    }
                }

                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    DerefOf (Local0 [0x02]) [0x02] = 0x2D
                }
                Else
                {
                    DerefOf (Local0 [0x02]) [0x02] = Zero
                }

                DerefOf (Local0 [0x02]) [0x03] = One
                Local1 = Zero
                Local1 |= One
                Local1 |= 0x02
                Local1 |= 0x08
                DerefOf (Local0 [0x02]) [0x04] = Local1
                DerefOf (Local0 [0x02]) [0x06] = ^^PCI0.SBRG.EC0.R531 /* \_SB_.PCI0.SBRG.EC0_.R531 */
                Local1 = Zero
                Local1 |= One
                Local1 |= 0x02
                Local1 |= 0x04
                DerefOf (Local0 [0x02]) [0x07] = Local1
                DerefOf (Local0 [0x02]) [0x08] = 0x2D
                Return (Local0)
            }

            Method (GM29, 0, NotSerialized)
            {
                Local0 = WBUF /* \WBUF */
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    Local1 = DerefOf (Local0 [Zero])
                    If ((Local1 != 0xFF))
                    {
                        ^^PCI0.SBRG.EC0.OSPT = Local1
                    }

                    Local1 = DerefOf (Local0 [One])
                    If ((Local1 != 0xFF))
                    {
                        ^^PCI0.SBRG.EC0.OSPL = Local1
                    }

                    Local3 = ^^PCI0.SBRG.EC0.R950 /* \_SB_.PCI0.SBRG.EC0_.R950 */
                    Local3 &= 0x0F
                    Local1 = DerefOf (Local0 [0x03])
                    If ((Local1 < 0xFF))
                    {
                        Local2 = (Local1 * 0x08)
                        ^^NPCF.DATP = Local2
                        CMSW (0x2A, Local2)
                        Notify (NPCF, 0xC0) // Hardware-Specific
                    }
                }

                Debug = "HP WMI Command type 0x29 for WMI 20008h command"
                WSMI (0x00020008, 0x29, 0x04, Zero, Zero)
                Return (WFDA ())
            }

            Method (GM2A, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x2A for WMI 20008h command"
                WSMI (0x00020008, 0x2A, Zero, 0x80, Zero)
                Local0 = WFDA ()
                Local1 = ^^PCI0.SBRG.EC0.R580 /* \_SB_.PCI0.SBRG.EC0_.R580 */
                DerefOf (Local0 [0x02]) [Zero] = Local1
                Local1 = ^^PCI0.SBRG.EC0.R390 /* \_SB_.PCI0.SBRG.EC0_.R390 */
                DerefOf (Local0 [0x02]) [0x02] = Local1
                Local1 = ^^PCI0.SBRG.EC0.R380 /* \_SB_.PCI0.SBRG.EC0_.R380 */
                DerefOf (Local0 [0x02]) [0x03] = Local1
                Local1 = ^^PCI0.SBRG.EC0.R370 /* \_SB_.PCI0.SBRG.EC0_.R370 */
                DerefOf (Local0 [0x02]) [0x04] = Local1
                Local1 = ^^NPCF.ATPP /* External reference */
                Local2 = (Local1 / 0x08)
                DerefOf (Local0 [0x02]) [0x07] = Local2
                Return (Local0)
            }

            Method (GM2B, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x2B for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04)
                        {
                             0x00                                             // .
                        }
                    }
                If ((^^PCI0.SBRG.EC0.RE20 == Zero))
                {
                    DerefOf (Local0 [0x02]) [Zero] = Zero
                }
                ElseIf ((^^PCI0.SBRG.EC0.RE20 == One))
                {
                    DerefOf (Local0 [0x02]) [Zero] = One
                }
                ElseIf ((^^PCI0.SBRG.EC0.RE20 == 0x02))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x02
                }
                ElseIf ((^^PCI0.SBRG.EC0.RE20 == 0x03))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x03
                }
                ElseIf ((^^PCI0.SBRG.EC0.RE20 == 0x04))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x04
                }
                ElseIf ((^^PCI0.SBRG.EC0.RE20 == 0x05))
                {
                    DerefOf (Local0 [0x02]) [Zero] = 0x05
                }

                Return (Local0)
            }

            Method (GM2C, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x2C for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80)
                        {
                             0x00                                             // .
                        }
                    }
                DerefOf (Local0 [0x02]) [Zero] = 0x21
                DerefOf (Local0 [0x02]) [One] = Zero
                DerefOf (Local0 [0x02]) [0x02] = Zero
                DerefOf (Local0 [0x02]) [0x03] = Zero
                Return (Local0)
            }

            Method (GM2D, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x2D for WMI 20008h command"
                WSMI (0x00020008, 0x2D, Zero, 0x80, Zero)
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80)
                        {
                             0x00                                             // .
                        }
                    }
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    Local1 = ^^PCI0.SBRG.EC0.RB10 /* \_SB_.PCI0.SBRG.EC0_.RB10 */
                    Local1 <<= 0x08
                    Local1 += ^^PCI0.SBRG.EC0.RB00 /* \_SB_.PCI0.SBRG.EC0_.RB00 */
                    Divide (Local1, 0x64, Local2, Local3)
                    If ((Local2 >= 0x32))
                    {
                        Local3 += One
                    }

                    DerefOf (Local0 [0x02]) [Zero] = Local3
                    Local1 = ^^PCI0.SBRG.EC0.RB30 /* \_SB_.PCI0.SBRG.EC0_.RB30 */
                    Local1 <<= 0x08
                    Local1 += ^^PCI0.SBRG.EC0.RB20 /* \_SB_.PCI0.SBRG.EC0_.RB20 */
                    Divide (Local1, 0x64, Local2, Local3)
                    If ((Local2 >= 0x32))
                    {
                        Local3 += One
                    }

                    DerefOf (Local0 [0x02]) [One] = Local3
                }

                Return (Local0)
            }

            Method (GM2E, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x2E for WMI 20008h command"
                WSMI (0x00020008, 0x2E, 0x80, Zero, Zero)
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local3 = DerefOf (Local1 [One])
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    ^^PCI0.SBRG.EC0.SRP1 = Local2
                    ^^PCI0.SBRG.EC0.SRP2 = Local3
                }

                Return (Local0)
            }

            Name (HPF1, Buffer (0x11)
            {
                /* 0000 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0010 */  0x00                                             // .
            })
            Name (HPF2, Buffer (0x11)
            {
                /* 0000 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0010 */  0x00                                             // .
            })
            Name (HPDB, Buffer (0x11)
            {
                /* 0000 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0010 */  0x00                                             // .
            })
            Name (P1F1, Buffer (0x0B)
            {
                /* 0000 */  0x12, 0x15, 0x18, 0x1A, 0x1C, 0x1D, 0x21, 0x24,  // ......!$
                /* 0008 */  0x2A, 0x2D, 0x30                                 // *-0
            })
            Name (P1F2, Buffer (0x0B)
            {
                /* 0000 */  0x10, 0x13, 0x15, 0x18, 0x1A, 0x20, 0x23, 0x27,  // ..... #'
                /* 0008 */  0x2C, 0x2F, 0x33                                 // ,/3
            })
            Name (P1DB, Buffer (0x0B)
            {
                /* 0000 */  0x16, 0x19, 0x1C, 0x1F, 0x22, 0x25, 0x28, 0x2B,  // ...."%(+
                /* 0008 */  0x2E, 0x30, 0x32                                 // .02
            })
            Method (GM2F, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x2F for WMI 20008h command"
                WSMI (0x00020008, 0x2F, Zero, 0x80, Zero)
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80)
                        {
                             0x00                                             // .
                        }
                    }
                DerefOf (Local0 [0x02]) [Zero] = 0x02
                DerefOf (Local0 [0x02]) [One] = 0x0C
                HPF1 = P1F1 /* \_SB_.WMID.P1F1 */
                HPF2 = P1F2 /* \_SB_.WMID.P1F2 */
                HPDB = P1DB /* \_SB_.WMID.P1DB */
                DerefOf (Local0 [0x02]) [0x02] = DerefOf (HPF1 [
                    Zero])
                DerefOf (Local0 [0x02]) [0x03] = DerefOf (HPF2 [
                    Zero])
                DerefOf (Local0 [0x02]) [0x04] = DerefOf (HPDB [
                    Zero])
                DerefOf (Local0 [0x02]) [0x05] = DerefOf (HPF1 [
                    One])
                DerefOf (Local0 [0x02]) [0x06] = DerefOf (HPF2 [
                    One])
                DerefOf (Local0 [0x02]) [0x07] = DerefOf (HPDB [
                    One])
                DerefOf (Local0 [0x02]) [0x08] = DerefOf (HPF1 [
                    0x02])
                DerefOf (Local0 [0x02]) [0x09] = DerefOf (HPF2 [
                    0x02])
                DerefOf (Local0 [0x02]) [0x0A] = DerefOf (HPDB [
                    0x02])
                DerefOf (Local0 [0x02]) [0x0B] = DerefOf (HPF1 [
                    0x03])
                DerefOf (Local0 [0x02]) [0x0C] = DerefOf (HPF2 [
                    0x03])
                DerefOf (Local0 [0x02]) [0x0D] = DerefOf (HPDB [
                    0x03])
                DerefOf (Local0 [0x02]) [0x0E] = DerefOf (HPF1 [
                    0x04])
                DerefOf (Local0 [0x02]) [0x0F] = DerefOf (HPF2 [
                    0x04])
                DerefOf (Local0 [0x02]) [0x10] = DerefOf (HPDB [
                    0x04])
                DerefOf (Local0 [0x02]) [0x11] = DerefOf (HPF1 [
                    0x05])
                DerefOf (Local0 [0x02]) [0x12] = DerefOf (HPF2 [
                    0x05])
                DerefOf (Local0 [0x02]) [0x13] = DerefOf (HPDB [
                    0x05])
                DerefOf (Local0 [0x02]) [0x14] = DerefOf (HPF1 [
                    0x06])
                DerefOf (Local0 [0x02]) [0x15] = DerefOf (HPF2 [
                    0x06])
                DerefOf (Local0 [0x02]) [0x16] = DerefOf (HPDB [
                    0x06])
                DerefOf (Local0 [0x02]) [0x17] = DerefOf (HPF1 [
                    0x07])
                DerefOf (Local0 [0x02]) [0x18] = DerefOf (HPF2 [
                    0x07])
                DerefOf (Local0 [0x02]) [0x19] = DerefOf (HPDB [
                    0x07])
                DerefOf (Local0 [0x02]) [0x1A] = DerefOf (HPF1 [
                    0x08])
                DerefOf (Local0 [0x02]) [0x1B] = DerefOf (HPF2 [
                    0x08])
                DerefOf (Local0 [0x02]) [0x1C] = DerefOf (HPDB [
                    0x08])
                DerefOf (Local0 [0x02]) [0x1D] = DerefOf (HPF1 [
                    0x09])
                DerefOf (Local0 [0x02]) [0x1E] = DerefOf (HPF2 [
                    0x09])
                DerefOf (Local0 [0x02]) [0x1F] = DerefOf (HPDB [
                    0x09])
                DerefOf (Local0 [0x02]) [0x20] = DerefOf (HPF1 [
                    0x0A])
                DerefOf (Local0 [0x02]) [0x21] = DerefOf (HPF2 [
                    0x0A])
                DerefOf (Local0 [0x02]) [0x22] = DerefOf (HPDB [
                    0x0A])
                DerefOf (Local0 [0x02]) [0x23] = DerefOf (HPF1 [
                    0x0B])
                DerefOf (Local0 [0x02]) [0x24] = DerefOf (HPF2 [
                    0x0B])
                DerefOf (Local0 [0x02]) [0x25] = DerefOf (HPDB [
                    0x0B])
                DerefOf (Local0 [0x02]) [0x26] = DerefOf (HPF1 [
                    0x0C])
                DerefOf (Local0 [0x02]) [0x27] = DerefOf (HPF2 [
                    0x0C])
                DerefOf (Local0 [0x02]) [0x28] = DerefOf (HPDB [
                    0x0C])
                DerefOf (Local0 [0x02]) [0x29] = DerefOf (HPF1 [
                    0x0D])
                DerefOf (Local0 [0x02]) [0x2A] = DerefOf (HPF2 [
                    0x0D])
                DerefOf (Local0 [0x02]) [0x2B] = DerefOf (HPDB [
                    0x0D])
                DerefOf (Local0 [0x02]) [0x2C] = DerefOf (HPF1 [
                    0x0E])
                DerefOf (Local0 [0x02]) [0x2D] = DerefOf (HPF2 [
                    0x0E])
                DerefOf (Local0 [0x02]) [0x2E] = DerefOf (HPDB [
                    0x0E])
                DerefOf (Local0 [0x02]) [0x2F] = DerefOf (HPF1 [
                    0x0F])
                DerefOf (Local0 [0x02]) [0x30] = DerefOf (HPF2 [
                    0x0F])
                DerefOf (Local0 [0x02]) [0x31] = DerefOf (HPDB [
                    0x0F])
                DerefOf (Local0 [0x02]) [0x32] = DerefOf (HPF1 [
                    0x10])
                DerefOf (Local0 [0x02]) [0x33] = DerefOf (HPF2 [
                    0x10])
                DerefOf (Local0 [0x02]) [0x34] = DerefOf (HPDB [
                    0x10])
                Return (Local0)
            }

            Method (GM30, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x30 for WMI 20008h command"
                WSMI (0x00020008, 0x30, Zero, 0x04, Zero)
                Return (WFDA ())
            }

            Method (GM31, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x31 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                Return (Local0)
            }

            Method (GM32, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x32 for WMI 20008h command"
                Local0 = WBUF /* \WBUF */
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (GM33, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x33 for WMI 20008h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    DerefOf (Local0 [0x02]) [Zero] = ^^PCI0.SBRG.EC0.R455 /* \_SB_.PCI0.SBRG.EC0_.R455 */
                }

                Return (Local0)
            }

            Method (GM34, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x34 for WMI 20008h command"
                Local0 = WBUF /* \WBUF */
                Local1 = DerefOf (Local0 [Zero])
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    ^^PCI0.SBRG.EC0.ETEG = Local1
                }

                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (GM35, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x35 for WMI 20008h command"
                WSMI (0x00020008, 0x35, 0x04, 0x80, Zero)
                Return (WFDA ())
            }

            Method (GM36, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x36 for WMI 20008h command"
                WSMI (0x00020008, 0x36, 0x04, 0x80, Zero)
                Return (WFDA ())
            }

            Method (GM37, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x37 for WMI 20008h command"
                WSMI (0x00020008, 0x37, 0x80, 0x04, Zero)
                Return (WFDA ())
            }

            Method (LM01, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x01 for WMI 20009h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                Local1 = One
                Local2 = Zero
                DerefOf (Local0 [0x02]) [Zero] = (Local1 | (
                    Local2 << One))
                DerefOf (Local0 [0x02]) [One] = Zero
                If ((^^PCI0.SBRG.EC0.RE20 == 0x02))
                {
                    Local1 = One
                }
                ElseIf ((^^PCI0.SBRG.EC0.RE20 == One))
                {
                    Local1 = One
                }
                Else
                {
                    Local1 = Zero
                }

                Local2 = 0x03
                DerefOf (Local0 [0x02]) [Zero] = (Local1 | (
                    Local2 << One))
                If ((^^PCI0.SBRG.EC0.ECON == One))
                {
                    DerefOf (Local0 [0x02]) [One] = ^^PCI0.SBRG.EC0.R570 /* \_SB_.PCI0.SBRG.EC0_.R570 */
                }

                Return (Local0)
            }

            Method (LM02, 0, Serialized)
            {
                Debug = "HP WMI Command type 0x02 for WMI 20009h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x80, 
                        Buffer (0x80){}
                    }
                Local1 = Zero
                Name (LDAT, Buffer (0x0C){})
                LDAT = ^^PCI0.SBRG.EC0.LRGB /* \_SB_.PCI0.SBRG.EC0_.LRGB */
                Local1 = 0x03
                DerefOf (Local0 [0x02]) [Zero] = Local1
                Switch (Local1)
                {
                    Case (Zero)
                    {
                    }
                    Case (One)
                    {
                        DerefOf (Local0 [0x02]) [One] = Zero
                        DerefOf (Local0 [0x02]) [0x02] = Zero
                        DerefOf (Local0 [0x02]) [0x03] = Zero
                    }
                    Case (0x02)
                    {
                        DerefOf (Local0 [0x02]) [One] = Zero
                        DerefOf (Local0 [0x02]) [0x02] = Zero
                        DerefOf (Local0 [0x02]) [0x03] = Zero
                        DerefOf (Local0 [0x02]) [0x04] = Zero
                        DerefOf (Local0 [0x02]) [0x05] = Zero
                        DerefOf (Local0 [0x02]) [0x06] = Zero
                        DerefOf (Local0 [0x02]) [0x07] = Zero
                        DerefOf (Local0 [0x02]) [0x08] = Zero
                        DerefOf (Local0 [0x02]) [0x09] = Zero
                        DerefOf (Local0 [0x02]) [0x0A] = Zero
                        DerefOf (Local0 [0x02]) [0x0B] = Zero
                        DerefOf (Local0 [0x02]) [0x0C] = Zero
                        DerefOf (Local0 [0x02]) [0x0D] = Zero
                        DerefOf (Local0 [0x02]) [0x0E] = Zero
                        DerefOf (Local0 [0x02]) [0x0F] = Zero
                        DerefOf (Local0 [0x02]) [0x10] = Zero
                        DerefOf (Local0 [0x02]) [0x11] = Zero
                    }
                    Case (0x03)
                    {
                        DerefOf (Local0 [0x02]) [0x19] = DerefOf (LDAT [
                            Zero])
                        DerefOf (Local0 [0x02]) [0x1A] = DerefOf (LDAT [
                            One])
                        DerefOf (Local0 [0x02]) [0x1B] = DerefOf (LDAT [
                            0x02])
                        DerefOf (Local0 [0x02]) [0x1C] = DerefOf (LDAT [
                            0x03])
                        DerefOf (Local0 [0x02]) [0x1D] = DerefOf (LDAT [
                            0x04])
                        DerefOf (Local0 [0x02]) [0x1E] = DerefOf (LDAT [
                            0x05])
                        DerefOf (Local0 [0x02]) [0x1F] = DerefOf (LDAT [
                            0x06])
                        DerefOf (Local0 [0x02]) [0x20] = DerefOf (LDAT [
                            0x07])
                        DerefOf (Local0 [0x02]) [0x21] = DerefOf (LDAT [
                            0x08])
                        DerefOf (Local0 [0x02]) [0x22] = DerefOf (LDAT [
                            0x09])
                        DerefOf (Local0 [0x02]) [0x23] = DerefOf (LDAT [
                            0x0A])
                        DerefOf (Local0 [0x02]) [0x24] = DerefOf (LDAT [
                            0x0B])
                    }
                    Case (0x04)
                    {
                        DerefOf (Local0 [0x02]) [One] = Zero
                        DerefOf (Local0 [0x02]) [0x02] = Zero
                        DerefOf (Local0 [0x02]) [0x03] = Zero
                        DerefOf (Local0 [0x02]) [0x04] = Zero
                        DerefOf (Local0 [0x02]) [0x05] = Zero
                        DerefOf (Local0 [0x02]) [0x06] = Zero
                        DerefOf (Local0 [0x02]) [0x07] = Zero
                        DerefOf (Local0 [0x02]) [0x08] = Zero
                        DerefOf (Local0 [0x02]) [0x09] = Zero
                        DerefOf (Local0 [0x02]) [0x0A] = Zero
                        DerefOf (Local0 [0x02]) [0x0B] = Zero
                        DerefOf (Local0 [0x02]) [0x0C] = Zero
                        DerefOf (Local0 [0x02]) [0x0D] = Zero
                        DerefOf (Local0 [0x02]) [0x0E] = Zero
                        DerefOf (Local0 [0x02]) [0x0F] = Zero
                    }
                    Default
                    {
                    }

                }

                Return (Local0)
            }

            Method (LM03, 0, Serialized)
            {
                Debug = "HP WMI Command type 0x03 for WMI 20009h command"
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Name (LDAT, Buffer (0x0C){})
                Local2 = 0x03
                Switch (Local2)
                {
                    Case (Zero)
                    {
                    }
                    Case (One)
                    {
                        Local3 = DerefOf (Local1 [One])
                        Local3 = DerefOf (Local1 [0x02])
                        Local3 = DerefOf (Local1 [0x03])
                    }
                    Case (0x02)
                    {
                        Local3 = DerefOf (Local1 [One])
                        Local3 = DerefOf (Local1 [0x02])
                        Local3 = DerefOf (Local1 [0x03])
                        Local3 = DerefOf (Local1 [0x04])
                        Local3 = DerefOf (Local1 [0x05])
                        Local3 = DerefOf (Local1 [0x06])
                        Local3 = DerefOf (Local1 [0x07])
                        Local3 = DerefOf (Local1 [0x08])
                        Local3 = DerefOf (Local1 [0x09])
                        Local3 = DerefOf (Local1 [0x0A])
                        Local3 = DerefOf (Local1 [0x0B])
                        Local3 = DerefOf (Local1 [0x0C])
                        Local3 = DerefOf (Local1 [0x0D])
                        Local3 = DerefOf (Local1 [0x0E])
                        Local3 = DerefOf (Local1 [0x0F])
                        Local3 = DerefOf (Local1 [0x10])
                        Local3 = DerefOf (Local1 [0x11])
                    }
                    Case (0x03)
                    {
                        LDAT [Zero] = DerefOf (Local1 [0x19])
                        LDAT [One] = DerefOf (Local1 [0x1A])
                        LDAT [0x02] = DerefOf (Local1 [0x1B])
                        LDAT [0x03] = DerefOf (Local1 [0x1C])
                        LDAT [0x04] = DerefOf (Local1 [0x1D])
                        LDAT [0x05] = DerefOf (Local1 [0x1E])
                        LDAT [0x06] = DerefOf (Local1 [0x1F])
                        LDAT [0x07] = DerefOf (Local1 [0x20])
                        LDAT [0x08] = DerefOf (Local1 [0x21])
                        LDAT [0x09] = DerefOf (Local1 [0x22])
                        LDAT [0x0A] = DerefOf (Local1 [0x23])
                        LDAT [0x0B] = DerefOf (Local1 [0x24])
                    }
                    Case (0x04)
                    {
                        Local3 = DerefOf (Local1 [One])
                        Local3 = DerefOf (Local1 [0x02])
                        Local3 = DerefOf (Local1 [0x03])
                        Local3 = DerefOf (Local1 [0x04])
                        Local3 = DerefOf (Local1 [0x05])
                        Local3 = DerefOf (Local1 [0x06])
                        Local3 = DerefOf (Local1 [0x07])
                        Local3 = DerefOf (Local1 [0x08])
                        Local3 = DerefOf (Local1 [0x09])
                        Local3 = DerefOf (Local1 [0x0A])
                        Local3 = DerefOf (Local1 [0x0B])
                        Local3 = DerefOf (Local1 [0x0C])
                        Local3 = DerefOf (Local1 [0x0D])
                        Local3 = DerefOf (Local1 [0x0E])
                        Local3 = DerefOf (Local1 [0x0F])
                    }
                    Default
                    {
                    }

                }

                ^^PCI0.SBRG.EC0.LRGB = LDAT /* \_SB_.WMID.LM03.LDAT */
                Stall (0x0F)
                ^^PCI0.SBRG.EC0.BRGB = LDAT /* \_SB_.WMID.LM03.LDAT */
                Stall (0x0F)
                ^^PCI0.SBRG.EC0.LCMC = One
                Return (Local0)
            }

            Method (LM04, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x04 for WMI 20009h command"
                Local0 = Package (0x03)
                    {
                        Zero, 
                        0x04, 
                        Buffer (0x04){}
                    }
                Local1 = 0x64
                DerefOf (Local0 [0x02]) [Zero] = Local1
                DerefOf (Local0 [0x02]) [Zero] = ^^PCI0.SBRG.EC0.LBRT /* \_SB_.PCI0.SBRG.EC0_.LBRT */
                Return (Local0)
            }

            Method (LM05, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x05 for WMI 20009h command"
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Local0 = Package (0x02)
                    {
                        Zero, 
                        Zero
                    }
                ^^PCI0.SBRG.EC0.LBRT = DerefOf (Local1 [Zero])
                ^^PCI0.SBRG.EC0.LCMC = One
                Return (Local0)
            }

            Method (LM06, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x06 for WMI 20009h command"
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (LM07, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x07 for WMI 20009h command"
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (LM08, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x08 for WMI 20009h command"
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (LM09, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x09 for WMI 20009h command"
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (LM0A, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x0A for WMI 20009h command"
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (LM0B, 0, NotSerialized)
            {
                Debug = "HP WMI Command type 0x0B for WMI 20009h command"
                Local1 = WBUF /* \WBUF */
                Local2 = DerefOf (Local1 [Zero])
                Return (Package (0x02)
                {
                    Zero, 
                    Zero
                })
            }

            Method (GWEV, 2, NotSerialized)
            {
                If ((WEI0 == Zero))
                {
                    WEI0 = Arg0
                    WED0 = Arg1
                }
                Else
                {
                    WEI1 = Arg0
                    WED1 = Arg1
                }

                Notify (WMID, 0x80) // Status Change
            }

            Method (_WED, 1, NotSerialized)  // _Wxx: Wake Event, xx=0x00-0xFF
            {
                If ((Arg0 == 0xA0))
                {
                    If ((DerefOf (N00E [Zero]) == Zero))
                    {
                        N007 = ST01 /* \_SB_.ST01 */
                        DerefOf (EVNT [Zero]) [One] = N007 /* \_SB_.N007 */
                        Return (DerefOf (EVNT [Zero]))
                    }

                    If ((DerefOf (N00E [Zero]) == One))
                    {
                        Return (DerefOf (EVNT [One]))
                    }
                    Else
                    {
                        Return (DerefOf (EVNT [0x02]))
                    }
                }

                Local0 = Buffer (0x08)
                    {
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   // ........
                    }
                CreateDWordField (Local0, Zero, EVID)
                CreateDWordField (Local0, 0x04, EVDA)
                EVID = WEI0 /* \_SB_.WMID.WEI0 */
                EVDA = WED0 /* \_SB_.WMID.WED0 */
                If ((WEI1 != Zero))
                {
                    WEI0 = WEI1 /* \_SB_.WMID.WEI1 */
                    WED0 = WED1 /* \_SB_.WMID.WED1 */
                    EVID = WEI0 /* \_SB_.WMID.WEI0 */
                    EVDA = WED0 /* \_SB_.WMID.WED0 */
                    WEI1 = Zero
                    WED1 = Zero
                    If ((WEVI == Zero))
                    {
                        WEVI = One
                        Notify (WMID, 0x80) // Status Change
                    }
                }
                Else
                {
                    WEI0 = Zero
                    WED0 = Zero
                }

                Return (Local0)
            }

            Name (WQAB, Buffer (0x1EE7)
            {
                /* 0000 */  0x46, 0x4F, 0x4D, 0x42, 0x01, 0x00, 0x00, 0x00,  // FOMB....
                /* 0008 */  0xD7, 0x1E, 0x00, 0x00, 0x84, 0xCA, 0x00, 0x00,  // ........
                /* 0010 */  0x44, 0x53, 0x00, 0x01, 0x1A, 0x7D, 0xDA, 0x54,  // DS...}.T
                /* 0018 */  0x18, 0x38, 0xA0, 0x00, 0x01, 0x06, 0x18, 0x42,  // .8.....B
                /* 0020 */  0x10, 0x4D, 0x10, 0x92, 0x46, 0x62, 0x02, 0x89,  // .M..Fb..
                /* 0028 */  0x80, 0x90, 0x18, 0x18, 0x14, 0x81, 0x85, 0x00,  // ........
                /* 0030 */  0x49, 0x02, 0x88, 0xC4, 0x41, 0xE1, 0x20, 0xD4,  // I...A. .
                /* 0038 */  0x9F, 0x40, 0x7E, 0x05, 0x20, 0x74, 0x28, 0x40,  // .@~. t(@
                /* 0040 */  0xA6, 0x00, 0x83, 0x02, 0x9C, 0x22, 0x88, 0xA0,  // ....."..
                /* 0048 */  0x57, 0x01, 0x36, 0x05, 0x98, 0x14, 0x60, 0x51,  // W.6...`Q
                /* 0050 */  0x80, 0x76, 0x01, 0x96, 0x05, 0xE8, 0x16, 0x20,  // .v..... 
                /* 0058 */  0x1D, 0x96, 0x88, 0x04, 0x47, 0x89, 0x01, 0x47,  // ....G..G
                /* 0060 */  0xE9, 0xC4, 0x16, 0x6E, 0xD8, 0xE0, 0x85, 0xA2,  // ...n....
                /* 0068 */  0x68, 0x06, 0x51, 0x12, 0x94, 0x8B, 0x20, 0x5D,  // h.Q... ]
                /* 0070 */  0x10, 0x52, 0x2E, 0xC0, 0x37, 0x82, 0x06, 0x10,  // .R..7...
                /* 0078 */  0xA5, 0x77, 0x01, 0xB6, 0x05, 0x98, 0x86, 0x27,  // .w.....'
                /* 0080 */  0xD2, 0x20, 0xE4, 0x60, 0x08, 0x54, 0xCE, 0x80,  // . .`.T..
                /* 0088 */  0x20, 0x69, 0x44, 0x21, 0x1E, 0xA7, 0x44, 0x08,  //  iD!..D.
                /* 0090 */  0x0A, 0x84, 0x90, 0xD4, 0xF1, 0xA0, 0xA0, 0x71,  // .......q
                /* 0098 */  0x88, 0xAD, 0xCE, 0x46, 0x93, 0xA9, 0x74, 0x7E,  // ...F..t~
                /* 00A0 */  0x48, 0x82, 0x70, 0xC6, 0x2A, 0x7E, 0x3A, 0x9A,  // H.p.*~:.
                /* 00A8 */  0xD0, 0xD9, 0x9C, 0x60, 0xE7, 0x18, 0x72, 0x3C,  // ...`..r<
                /* 00B0 */  0x48, 0xF4, 0x20, 0xB8, 0x00, 0x0F, 0x1C, 0x2C,  // H. ....,
                /* 00B8 */  0x34, 0x84, 0x22, 0x6B, 0x80, 0xC1, 0x8C, 0xDD,  // 4."k....
                /* 00C0 */  0x63, 0xB1, 0x0B, 0x4E, 0x0A, 0xEC, 0x61, 0xB3,  // c..N..a.
                /* 00C8 */  0x01, 0x19, 0xA2, 0x24, 0x38, 0xD4, 0x11, 0xC0,  // ...$8...
                /* 00D0 */  0x12, 0x05, 0x98, 0x1F, 0x87, 0x0C, 0x0F, 0x95,  // ........
                /* 00D8 */  0x8C, 0x25, 0x24, 0x1B, 0xAB, 0x87, 0xC2, 0xA5,  // .%$.....
                /* 00E0 */  0x40, 0x68, 0x6C, 0x27, 0xED, 0x19, 0x45, 0x2C,  // @hl'..E,
                /* 00E8 */  0x79, 0x4A, 0x82, 0x49, 0xE0, 0x51, 0x44, 0x36,  // yJ.I.QD6
                /* 00F0 */  0x1A, 0x27, 0x28, 0x1B, 0x1A, 0x25, 0x03, 0x42,  // .'(..%.B
                /* 00F8 */  0x9E, 0x05, 0x58, 0x07, 0x26, 0x04, 0x76, 0x2F,  // ..X.&.v/
                /* 0100 */  0xC0, 0x9A, 0x00, 0x73, 0xB3, 0x90, 0xB1, 0xB9,  // ...s....
                /* 0108 */  0xE8, 0xFF, 0x0F, 0x71, 0xB0, 0x31, 0xDA, 0x9A,  // ...q.1..
                /* 0110 */  0xAE, 0x90, 0xC2, 0xC4, 0x88, 0x12, 0x2C, 0x5E,  // ......,^
                /* 0118 */  0xC5, 0xC3, 0x10, 0xCA, 0x93, 0x42, 0xA8, 0x48,  // .....B.H
                /* 0120 */  0x95, 0xA1, 0x68, 0xB4, 0x51, 0x2A, 0x14, 0xE0,  // ..h.Q*..
                /* 0128 */  0x4C, 0x80, 0x30, 0x5C, 0x1D, 0x03, 0x82, 0x46,  // L.0\...F
                /* 0130 */  0x88, 0x15, 0x29, 0x56, 0xFB, 0x83, 0x20, 0xF1,  // ..)V.. .
                /* 0138 */  0x2D, 0x40, 0x54, 0x01, 0xA2, 0x48, 0xA3, 0x41,  // -@T..H.A
                /* 0140 */  0x9D, 0x03, 0x3C, 0x5C, 0x0F, 0xF5, 0xF0, 0x3D,  // ..<\...=
                /* 0148 */  0xF6, 0x93, 0x0C, 0x72, 0x90, 0x67, 0xF1, 0xA8,  // ...r.g..
                /* 0150 */  0x70, 0x9C, 0x06, 0x49, 0xE0, 0x0B, 0x80, 0x4F,  // p..I...O
                /* 0158 */  0x08, 0x1E, 0x38, 0xDE, 0x35, 0xA0, 0x66, 0x7C,  // ..8.5.f|
                /* 0160 */  0xBC, 0x4C, 0x10, 0x1C, 0x6A, 0x88, 0x1E, 0x68,  // .L..j..h
                /* 0168 */  0xB8, 0x13, 0x38, 0x44, 0x06, 0xE8, 0x49, 0x3D,  // ..8D..I=
                /* 0170 */  0x52, 0x60, 0x07, 0x77, 0x32, 0xEF, 0x01, 0xAF,  // R`.w2...
                /* 0178 */  0x0A, 0xCD, 0x5E, 0x12, 0x08, 0xC1, 0xF1, 0xF8,  // ..^.....
                /* 0180 */  0x7E, 0xC0, 0x26, 0x9C, 0xC0, 0xF2, 0x07, 0x81,  // ~.&.....
                /* 0188 */  0x1A, 0x99, 0xA1, 0x3D, 0xCA, 0xD3, 0x8A, 0x19,  // ...=....
                /* 0190 */  0xF2, 0x31, 0xC1, 0x04, 0x16, 0x0B, 0x21, 0x05,  // .1....!.
                /* 0198 */  0x10, 0x1A, 0x0F, 0xF8, 0x6F, 0x00, 0x8F, 0x17,  // ....o...
                /* 01A0 */  0xBE, 0x12, 0xC4, 0xF6, 0x80, 0x12, 0x0C, 0x0B,  // ........
                /* 01A8 */  0x21, 0x23, 0xAB, 0xF0, 0x78, 0xE8, 0x28, 0x7C,  // !#..x.(|
                /* 01B0 */  0x95, 0x38, 0x9C, 0xD3, 0x8A, 0x67, 0x82, 0xE1,  // .8...g..
                /* 01B8 */  0x20, 0xF4, 0x05, 0x90, 0x00, 0x51, 0xE7, 0x0C,  //  ....Q..
                /* 01C0 */  0xD4, 0x61, 0xC1, 0xE7, 0x04, 0x76, 0x33, 0x38,  // .a...v38
                /* 01C8 */  0x83, 0x47, 0x00, 0x8F, 0xE4, 0x84, 0xFC, 0x2B,  // .G.....+
                /* 01D0 */  0xF1, 0xC0, 0xE0, 0x03, 0xE2, 0xEF, 0x1F, 0xA7,  // ........
                /* 01D8 */  0xEC, 0x11, 0x9C, 0xA9, 0x01, 0x7D, 0x1C, 0xF0,  // .....}..
                /* 01E0 */  0xFF, 0x7F, 0x28, 0x7C, 0x88, 0x1E, 0xDF, 0x29,  // ..(|...)
                /* 01E8 */  0x1F, 0xAF, 0x4F, 0x17, 0x96, 0x35, 0x4E, 0xE8,  // ..O..5N.
                /* 01F0 */  0x77, 0x08, 0x9F, 0x38, 0x7C, 0x64, 0x71, 0x44,  // w..8|dqD
                /* 01F8 */  0x08, 0x39, 0x39, 0x05, 0xA0, 0x81, 0x4F, 0xF7,  // .99...O.
                /* 0200 */  0xEC, 0x22, 0x9C, 0xAE, 0x27, 0xE5, 0x40, 0xC3,  // ."..'.@.
                /* 0208 */  0xA0, 0xE3, 0x04, 0xC7, 0x79, 0x00, 0x1C, 0xE3,  // ....y...
                /* 0210 */  0x84, 0x7F, 0x2E, 0x80, 0x3F, 0x40, 0x7E, 0xCA,  // ....?@~.
                /* 0218 */  0x78, 0xC5, 0x48, 0xE0, 0x98, 0x23, 0x44, 0x9F,  // x.H..#D.
                /* 0220 */  0x6B, 0x3C, 0x42, 0x2C, 0xFC, 0x53, 0x45, 0xE1,  // k<B,.SE.
                /* 0228 */  0x03, 0x21, 0x63, 0x04, 0x17, 0xA0, 0xC7, 0x08,  // .!c.....
                /* 0230 */  0x7C, 0xFF, 0x48, 0x1A, 0x23, 0xF2, 0x28, 0xC1,  // |.H.#.(.
                /* 0238 */  0xD5, 0x1F, 0x34, 0xE8, 0x00, 0x71, 0xFF, 0xFF,  // ..4..q..
                /* 0240 */  0x01, 0xC2, 0x07, 0xF5, 0x00, 0x81, 0x6F, 0xF4,  // ......o.
                /* 0248 */  0xA3, 0x07, 0x7A, 0x5C, 0x16, 0x7D, 0x1E, 0x90,  // ..z\.}..
                /* 0250 */  0xF1, 0x13, 0x8D, 0xE6, 0xC5, 0x4F, 0x07, 0xFC,  // .....O..
                /* 0258 */  0xF0, 0x01, 0x1E, 0x50, 0x0F, 0x09, 0x07, 0x8A,  // ...P....
                /* 0260 */  0x99, 0x36, 0x07, 0x7D, 0x76, 0x39, 0x74, 0xEC,  // .6.}v9t.
                /* 0268 */  0x70, 0xC1, 0x7F, 0x02, 0x01, 0x97, 0xBC, 0x43,  // p......C
                /* 0270 */  0x18, 0x28, 0x46, 0x8C, 0x3F, 0x07, 0xF9, 0x14,  // .(F.?...
                /* 0278 */  0x06, 0xFE, 0xFF, 0xFF, 0x29, 0x0C, 0xFC, 0xC3,  // ....)...
                /* 0280 */  0xE1, 0x41, 0x9E, 0x0E, 0x3E, 0x6D, 0x51, 0xE9,  // .A..>mQ.
                /* 0288 */  0x30, 0xA8, 0x03, 0x17, 0x60, 0x65, 0x12, 0x11,  // 0...`e..
                /* 0290 */  0x9E, 0x25, 0x6A, 0x83, 0xD0, 0xA9, 0xE1, 0x6D,  // .%j....m
                /* 0298 */  0xE2, 0x6D, 0xCB, 0xB7, 0x80, 0x38, 0xA7, 0xD9,  // .m...8..
                /* 02A0 */  0xDB, 0x81, 0x8B, 0x60, 0x44, 0xA8, 0x19, 0x8A,  // ...`D...
                /* 02A8 */  0x9C, 0xB4, 0x22, 0xC6, 0x88, 0xF2, 0xB8, 0x65,  // .."....e
                /* 02B0 */  0x94, 0xB7, 0xAD, 0x17, 0x80, 0x78, 0x27, 0xF6,  // .....x'.
                /* 02B8 */  0xBC, 0x65, 0x8C, 0xE0, 0x91, 0x1F, 0xB8, 0x58,  // .e.....X
                /* 02C0 */  0x8C, 0xD5, 0xEB, 0xBF, 0xE6, 0x03, 0x17, 0xE0,  // ........
                /* 02C8 */  0xEC, 0xFF, 0x7F, 0xE0, 0x02, 0x38, 0x14, 0xF4,  // .....8..
                /* 02D0 */  0x30, 0x84, 0x1E, 0x86, 0xA7, 0x72, 0x2E, 0x0F,  // 0....r..
                /* 02D8 */  0x91, 0xA7, 0x12, 0x31, 0x6A, 0x98, 0xA8, 0xCF,  // ...1j...
                /* 02E0 */  0x50, 0xBE, 0x5B, 0xF8, 0x40, 0x04, 0xBE, 0x33,  // P.[.@..3
                /* 02E8 */  0x17, 0xF0, 0xFB, 0xFF, 0x1F, 0x88, 0xE0, 0x1C,  // ........
                /* 02F0 */  0x53, 0x70, 0x67, 0x1A, 0xF0, 0xF8, 0x9C, 0x81,  // Spg.....
                /* 02F8 */  0x40, 0x4E, 0xC5, 0x87, 0x1A, 0xC0, 0x82, 0xE8,  // @N......
                /* 0300 */  0x27, 0x84, 0x4F, 0x34, 0x54, 0x26, 0x0C, 0xEA,  // '.O4T&..
                /* 0308 */  0x50, 0x03, 0x58, 0xB9, 0xC2, 0x3C, 0x8D, 0x9E,  // P.X..<..
                /* 0310 */  0xF3, 0xB3, 0x8C, 0x4F, 0x35, 0x3E, 0x94, 0x1A,  // ...O5>..
                /* 0318 */  0xC7, 0x10, 0x2F, 0x33, 0x0F, 0x35, 0x3E, 0x16,  // ../3.5>.
                /* 0320 */  0xBC, 0x92, 0xFA, 0x50, 0x63, 0xA8, 0x38, 0x0F,  // ...Pc.8.
                /* 0328 */  0x35, 0x1E, 0x6E, 0xA0, 0xA8, 0x6F, 0x36, 0xCF,  // 5.n..o6.
                /* 0330 */  0x36, 0x46, 0x8F, 0xEF, 0x1B, 0xAA, 0x21, 0x1E,  // 6F....!.
                /* 0338 */  0x6A, 0x98, 0xE4, 0x95, 0x6A, 0x2C, 0x3E, 0xD4,  // j...j,>.
                /* 0340 */  0x80, 0xE3, 0xFF, 0x7F, 0xA8, 0x01, 0xF8, 0xFF,  // ........
                /* 0348 */  0xFF, 0x3F, 0xD4, 0x00, 0x8E, 0x8E, 0x06, 0x70,  // .?.....p
                /* 0350 */  0x8E, 0x8C, 0xB8, 0xA3, 0x01, 0xB8, 0x0E, 0xA5,  // ........
                /* 0358 */  0xC0, 0xE1, 0x68, 0x00, 0x3C, 0x8E, 0x42, 0x60,  // ..h.<.B`
                /* 0360 */  0xBE, 0xD0, 0xF8, 0x28, 0x04, 0x2C, 0xFE, 0xFF,  // ...(.,..
                /* 0368 */  0x47, 0x21, 0xF0, 0xCB, 0x3E, 0x07, 0xA1, 0x84,  // G!..>...
                /* 0370 */  0x1E, 0x85, 0x00, 0x41, 0xB7, 0x9F, 0xA7, 0x88,  // ...A....
                /* 0378 */  0x67, 0x1F, 0x5F, 0x7E, 0x1E, 0x08, 0x22, 0xBC,  // g._~..".
                /* 0380 */  0xE6, 0xFB, 0x14, 0xE4, 0x43, 0xBE, 0x8F, 0x42,  // ....C..B
                /* 0388 */  0x0C, 0xC6, 0x50, 0xBE, 0x06, 0xF9, 0x28, 0xC4,  // ..P...(.
                /* 0390 */  0xA0, 0x5E, 0x83, 0x7C, 0xDF, 0x37, 0xC8, 0xE3,  // .^.|.7..
                /* 0398 */  0x45, 0x90, 0xD8, 0xCF, 0x04, 0x3E, 0x0A, 0x31,  // E....>.1
                /* 03A0 */  0xD1, 0x47, 0x21, 0x40, 0xE1, 0xFF, 0xFF, 0x28,  // .G!@...(
                /* 03A8 */  0x04, 0xF0, 0xFF, 0xFF, 0x7F, 0x14, 0x02, 0x9C,  // ........
                /* 03B0 */  0x05, 0x38, 0x1A, 0x80, 0x6E, 0x5A, 0x8F, 0x42,  // .8..nZ.B
                /* 03B8 */  0xE0, 0xBD, 0xB3, 0x9C, 0xF6, 0x09, 0xF8, 0x2C,  // .......,
                /* 03C0 */  0x04, 0x98, 0xFD, 0xFF, 0x9F, 0x85, 0x80, 0xD9,  // ........
                /* 03C8 */  0x51, 0xE8, 0x28, 0xCE, 0xF2, 0x55, 0xE8, 0x09,  // Q.(..U..
                /* 03D0 */  0xE0, 0x05, 0x20, 0x46, 0x98, 0x77, 0xA0, 0x97,  // .. F.w..
                /* 03D8 */  0x4C, 0x76, 0x17, 0x37, 0xCE, 0x93, 0xCB, 0x59,  // Lv.7...Y
                /* 03E0 */  0x3C, 0x89, 0xFB, 0x12, 0xE4, 0x03, 0xC5, 0xB3,  // <.......
                /* 03E8 */  0x90, 0xA1, 0x4E, 0x37, 0xE8, 0x1B, 0xB9, 0x07,  // ..N7....
                /* 03F0 */  0x16, 0x33, 0x7E, 0x88, 0xE7, 0x21, 0x43, 0x3C,  // .3~..!C<
                /* 03F8 */  0x0B, 0x01, 0xEC, 0xFA, 0xFF, 0x9F, 0x85, 0x00,  // ........
                /* 0400 */  0xFE, 0xFF, 0xFF, 0x8F, 0x06, 0xF0, 0x5F, 0x00,  // ......_.
                /* 0408 */  0x3E, 0x0B, 0x01, 0xCF, 0x13, 0xC0, 0x83, 0xB6,  // >.......
                /* 0410 */  0xCF, 0x42, 0x00, 0x67, 0x0E, 0x97, 0xE7, 0xFF,  // .B.g....
                /* 0418 */  0x0A, 0x74, 0x2C, 0xEF, 0x11, 0x9E, 0xF5, 0x49,  // .t,....I
                /* 0420 */  0xBE, 0x5E, 0x7A, 0xA6, 0x0F, 0x05, 0xCF, 0x42,  // .^z....B
                /* 0428 */  0x0C, 0xEB, 0x30, 0x7C, 0x16, 0x62, 0x10, 0x2F,  // ..0|.b./
                /* 0430 */  0x9A, 0x86, 0x78, 0xE1, 0xF4, 0x61, 0xC0, 0xFF,  // ..x..a..
                /* 0438 */  0x7F, 0xBC, 0xC0, 0xAF, 0x9C, 0x06, 0x0A, 0x12,  // ........
                /* 0440 */  0xE8, 0x59, 0x08, 0x60, 0xFC, 0xFF, 0xFF, 0x2C,  // .Y.`...,
                /* 0448 */  0x04, 0x90, 0x71, 0x8D, 0x3A, 0x0B, 0x01, 0xCB,  // ..q.:...
                /* 0450 */  0xDB, 0xCA, 0x33, 0xB6, 0x4F, 0x2B, 0x09, 0xFE,  // ..3.O+..
                /* 0458 */  0xFF, 0xCF, 0x42, 0x80, 0x83, 0x5C, 0x46, 0x0E,  // ..B..\F.
                /* 0460 */  0x42, 0x98, 0x88, 0x0F, 0x07, 0x1F, 0x33, 0x01,  // B.....3.
                /* 0468 */  0x3D, 0x53, 0x7C, 0x71, 0x37, 0xC6, 0x13, 0xC0,  // =S|q7...
                /* 0470 */  0x8B, 0xC4, 0x63, 0x26, 0x3B, 0x6A, 0x1A, 0xE6,  // ..c&;j..
                /* 0478 */  0x59, 0xC8, 0x78, 0x67, 0xF1, 0x1A, 0xF0, 0x04,  // Y.xg....
                /* 0480 */  0xEF, 0xC9, 0x3F, 0x0B, 0x31, 0xB0, 0xC3, 0x0A,  // ..?.1...
                /* 0488 */  0xF6, 0x28, 0x64, 0x50, 0x83, 0xC7, 0x0E, 0x11,  // .(dP....
                /* 0490 */  0x26, 0xD0, 0xB3, 0x10, 0x8B, 0xFB, 0x5C, 0xD1,  // &.....\.
                /* 0498 */  0x79, 0xC2, 0x67, 0x21, 0xE0, 0xFD, 0xFF, 0x3F,  // y.g!...?
                /* 04A0 */  0x4B, 0xC0, 0xBD, 0x1A, 0x3C, 0x0B, 0x01, 0x26,  // K...<..&
                /* 04A8 */  0x0E, 0x1B, 0x3E, 0x6B, 0x80, 0x67, 0xF8, 0x1E,  // ..>k.g..
                /* 04B0 */  0xD5, 0x39, 0x3C, 0x1E, 0x03, 0xFF, 0xAC, 0x3A,  // .9<....:
                /* 04B8 */  0xCE, 0x09, 0x2C, 0xF7, 0xA2, 0x65, 0xE3, 0x40,  // ..,..e.@
                /* 04C0 */  0x43, 0x47, 0x64, 0x75, 0x40, 0x1A, 0x1B, 0xE6,  // CGdu@...
                /* 04C8 */  0x52, 0x12, 0xF9, 0xE4, 0xD8, 0xA8, 0xAD, 0x08,  // R.......
                /* 04D0 */  0x4E, 0x67, 0x26, 0x9F, 0x00, 0xAC, 0x85, 0x42,  // Ng&....B
                /* 04D8 */  0x0A, 0x68, 0x34, 0x16, 0xC3, 0x3B, 0xF3, 0xD1,  // .h4..;..
                /* 04E0 */  0x89, 0x82, 0x18, 0xD0, 0xC7, 0x21, 0xDB, 0x38,  // .....!.8
                /* 04E8 */  0x14, 0xA0, 0xF6, 0xA2, 0x29, 0x90, 0x73, 0x0E,  // ....).s.
                /* 04F0 */  0x46, 0xFF, 0xEC, 0xE8, 0x6C, 0x7C, 0x27, 0xE0,  // F...l|'.
                /* 04F8 */  0x1A, 0x20, 0x74, 0x4A, 0x30, 0xB4, 0xD5, 0x08,  // . tJ0...
                /* 0500 */  0xF8, 0xFF, 0xCF, 0x12, 0x03, 0x66, 0xFC, 0xA7,  // .....f..
                /* 0508 */  0x18, 0x13, 0xF8, 0x1C, 0x83, 0x3F, 0x18, 0xE0,  // .....?..
                /* 0510 */  0x07, 0xFE, 0x62, 0x50, 0xF5, 0xBD, 0x40, 0xF7,  // ..bP..@.
                /* 0518 */  0x05, 0xAB, 0xBB, 0xC9, 0x40, 0x98, 0x91, 0x09,  // ....@...
                /* 0520 */  0xEA, 0x3B, 0x1D, 0x80, 0x02, 0xC8, 0x17, 0x02,  // .;......
                /* 0528 */  0x9F, 0xA3, 0x1E, 0x0A, 0xD8, 0x44, 0x42, 0x84,  // .....DB.
                /* 0530 */  0x89, 0x66, 0x74, 0xC4, 0x84, 0x51, 0xD1, 0x27,  // .ft..Q.'
                /* 0538 */  0x4C, 0x41, 0x3C, 0x61, 0xC7, 0x9A, 0x30, 0x7A,  // LA<a..0z
                /* 0540 */  0x26, 0xBE, 0xE8, 0xB0, 0x11, 0x63, 0x42, 0x5C,  // &....cB\
                /* 0548 */  0x3D, 0xA0, 0x4D, 0x30, 0xA8, 0x2F, 0x45, 0xB0,  // =.M0./E.
                /* 0550 */  0x86, 0xCC, 0xC7, 0xE2, 0x0B, 0x04, 0x6E, 0xCA,  // ......n.
                /* 0558 */  0x60, 0x9C, 0x13, 0xBB, 0x26, 0xF8, 0xB2, 0x83,  // `...&...
                /* 0560 */  0x9B, 0x33, 0x18, 0xE1, 0x31, 0x77, 0x31, 0x7E,  // .3..1w1~
                /* 0568 */  0x75, 0xF2, 0xE8, 0xF8, 0x41, 0xC1, 0x37, 0x1C,  // u...A.7.
                /* 0570 */  0x86, 0xFD, 0x64, 0xE6, 0x19, 0xBD, 0x97, 0xF9,  // ..d.....
                /* 0578 */  0x1A, 0x87, 0x81, 0xF5, 0x78, 0x39, 0xAC, 0xD1,  // ....x9..
                /* 0580 */  0xC2, 0x1E, 0xDA, 0x7B, 0x88, 0xFF, 0xFF, 0x87,  // ...{....
                /* 0588 */  0x18, 0x9F, 0x27, 0x8C, 0x11, 0xD6, 0xB7, 0x17,  // ..'.....
                /* 0590 */  0x70, 0xDC, 0xB3, 0xE0, 0xDF, 0x35, 0xC0, 0x73,  // p....5.s
                /* 0598 */  0x09, 0xF1, 0x5D, 0x03, 0x60, 0xE0, 0xFF, 0xFF,  // ..].`...
                /* 05A0 */  0xAE, 0x01, 0x9C, 0xAE, 0x09, 0xBE, 0x6B, 0x00,  // ......k.
                /* 05A8 */  0xEF, 0xA1, 0xFB, 0xAE, 0x01, 0x5C, 0xB3, 0xDF,  // .....\..
                /* 05B0 */  0x35, 0x50, 0xC7, 0x00, 0x2B, 0xBC, 0x6B, 0x40,  // 5P..+.k@
                /* 05B8 */  0xBB, 0xB2, 0xBD, 0xAF, 0x3D, 0x61, 0x59, 0xD3,  // ....=aY.
                /* 05C0 */  0x65, 0x03, 0xA5, 0xE6, 0xB2, 0x01, 0x28, 0xF8,  // e.....(.
                /* 05C8 */  0xFF, 0x5F, 0x36, 0x00, 0x03, 0x52, 0x26, 0x8C,  // ._6..R&.
                /* 05D0 */  0x0A, 0x3F, 0x61, 0x0A, 0xE2, 0x09, 0x3B, 0xD8,  // .?a...;.
                /* 05D8 */  0x65, 0x03, 0x14, 0x31, 0x2E, 0x1B, 0xA0, 0x1F,  // e..1....
                /* 05E0 */  0xDB, 0xCB, 0x06, 0x30, 0xB8, 0x27, 0xF0, 0xDB,  // ...0.'..
                /* 05E8 */  0x06, 0xF0, 0x86, 0xF4, 0x6D, 0x03, 0xAC, 0xFF,  // ....m...
                /* 05F0 */  0xFF, 0xDB, 0x06, 0x58, 0xF3, 0xDF, 0x36, 0x50,  // ...X..6P
                /* 05F8 */  0x1C, 0x56, 0x79, 0xDB, 0x80, 0x78, 0x92, 0x67,  // .Vy..x.g
                /* 0600 */  0x04, 0x56, 0x75, 0xDD, 0x40, 0xE9, 0xB9, 0x6E,  // .Vu.@..n
                /* 0608 */  0x00, 0x24, 0x10, 0x33, 0x61, 0x54, 0xFC, 0x09,  // .$.3aT..
                /* 0610 */  0x53, 0x10, 0x4F, 0xD8, 0xD1, 0xAE, 0x1B, 0xA0,  // S.O.....
                /* 0618 */  0x08, 0x72, 0xDD, 0x00, 0xFD, 0xBC, 0x12, 0xFC,  // .r......
                /* 0620 */  0xFF, 0x5F, 0x37, 0x80, 0xC1, 0x45, 0x01, 0x73,  // ._7..E.s
                /* 0628 */  0xDF, 0x00, 0xDE, 0xB0, 0xFC, 0xBE, 0x01, 0xF8,  // ........
                /* 0630 */  0xB8, 0x89, 0x63, 0xEE, 0x1B, 0x80, 0x99, 0xFF,  // ..c.....
                /* 0638 */  0xFF, 0x7D, 0x03, 0x60, 0xCF, 0x45, 0x01, 0x77,  // .}.`.E.w
                /* 0640 */  0xDF, 0x00, 0xDE, 0x17, 0x69, 0xDF, 0x37, 0xC0,  // ....i.7.
                /* 0648 */  0xFC, 0xFF, 0xBF, 0x6F, 0x80, 0x51, 0xDA, 0xFA,  // ...o.Q..
                /* 0650 */  0x3D, 0x38, 0x7A, 0x42, 0xF0, 0xF8, 0x70, 0xF7,  // =8zB..p.
                /* 0658 */  0x4B, 0x8F, 0xCF, 0x77, 0x73, 0x70, 0x0C, 0xF2,  // K..wsp..
                /* 0660 */  0x18, 0x0F, 0xED, 0x80, 0x5F, 0xDF, 0x3D, 0x31,  // ...._.=1
                /* 0668 */  0xDF, 0xCD, 0x81, 0xFF, 0x99, 0xE0, 0x78, 0x30,  // ......x0
                /* 0670 */  0xD0, 0x38, 0xC4, 0x56, 0x2F, 0x0D, 0xE4, 0x68,  // .8.V/..h
                /* 0678 */  0x70, 0x7E, 0xB8, 0x33, 0x02, 0xC3, 0x2A, 0xFE,  // p~.3..*.
                /* 0680 */  0xE4, 0x8F, 0x70, 0x8E, 0xA1, 0xB3, 0xC3, 0x41,  // ..p....A
                /* 0688 */  0x62, 0x07, 0xC1, 0x83, 0xAD, 0xDA, 0x04, 0x0A,  // b.......
                /* 0690 */  0x0D, 0xA1, 0x28, 0x30, 0x28, 0x16, 0x1F, 0x30,  // ..(0(..0
                /* 0698 */  0xF0, 0xC3, 0x66, 0x67, 0x01, 0x26, 0x09, 0x0E,  // ..fg.&..
                /* 06A0 */  0x75, 0x04, 0xF0, 0x7D, 0xA2, 0xF9, 0x71, 0xE8,  // u..}..q.
                /* 06A8 */  0x6E, 0x70, 0xA8, 0x1E, 0xCB, 0x43, 0x01, 0x3D,  // np...C.=
                /* 06B0 */  0x03, 0xE2, 0x8E, 0x19, 0x64, 0xD2, 0x9E, 0x51,  // ....d..Q
                /* 06B8 */  0xC4, 0xA7, 0x84, 0x53, 0x0A, 0x93, 0xC0, 0xE7,  // ...S....
                /* 06C0 */  0x07, 0x86, 0xC6, 0x09, 0x5E, 0x1B, 0x42, 0xF3,  // ....^.B.
                /* 06C8 */  0xFF, 0xFF, 0x49, 0x81, 0x79, 0xBE, 0x63, 0x08,  // ..I.y.c.
                /* 06D0 */  0xD8, 0x04, 0x76, 0x7F, 0xC9, 0x90, 0xB5, 0x81,  // ..v.....
                /* 06D8 */  0xEB, 0x96, 0x64, 0x88, 0xDE, 0x70, 0x64, 0x0B,  // ..d..pd.
                /* 06E0 */  0x45, 0xD3, 0x89, 0xF2, 0xBE, 0x11, 0xC5, 0xCE,  // E.......
                /* 06E8 */  0x10, 0x84, 0x11, 0x25, 0x58, 0x90, 0x47, 0x85,  // ...%X.G.
                /* 06F0 */  0x58, 0x51, 0x5E, 0x0A, 0x8C, 0x10, 0x31, 0xC4,  // XQ^...1.
                /* 06F8 */  0x2B, 0x47, 0xA0, 0x13, 0x0E, 0x1F, 0xE4, 0xB1,  // +G......
                /* 0700 */  0x29, 0x4E, 0xFB, 0x83, 0x20, 0xB1, 0x9E, 0x04,  // )N.. ...
                /* 0708 */  0x1A, 0x8B, 0x23, 0x8D, 0x06, 0x75, 0x0E, 0xF0,  // ..#..u..
                /* 0710 */  0x70, 0x7D, 0x88, 0xF1, 0xF0, 0x1F, 0x42, 0x0C,  // p}....B.
                /* 0718 */  0x72, 0x90, 0xE7, 0xF6, 0xA8, 0x70, 0x9C, 0xBE,  // r....p..
                /* 0720 */  0x4A, 0x98, 0xE0, 0x05, 0xC0, 0x07, 0x15, 0x38,  // J......8
                /* 0728 */  0xAE, 0x01, 0x35, 0xE3, 0x67, 0x0C, 0xB0, 0x1C,  // ..5.g...
                /* 0730 */  0xC7, 0x7D, 0x52, 0x81, 0x3B, 0x1E, 0xDF, 0x0F,  // .}R.;...
                /* 0738 */  0xD8, 0x84, 0x13, 0x58, 0xFE, 0x20, 0x50, 0xC7,  // ...X. P.
                /* 0740 */  0x19, 0x3E, 0xCF, 0x17, 0x16, 0x43, 0x3E, 0x26,  // .>...C>&
                /* 0748 */  0x98, 0xC0, 0x62, 0x4F, 0x36, 0x74, 0x3C, 0xE0,  // ..bO6t<.
                /* 0750 */  0xBF, 0xC7, 0x3C, 0x5E, 0xF8, 0x64, 0xE2, 0xF9,  // ..<^.d..
                /* 0758 */  0x9A, 0x60, 0x44, 0x08, 0x39, 0x19, 0x0F, 0xFA,  // .`D.9...
                /* 0760 */  0x0E, 0x81, 0xB9, 0xDE, 0xB0, 0x73, 0x0B, 0x17,  // .....s..
                /* 0768 */  0x75, 0xD0, 0x40, 0x9D, 0x16, 0x7C, 0x50, 0x60,  // u.@..|P`
                /* 0770 */  0x37, 0x23, 0xCC, 0x71, 0x9D, 0x9F, 0x55, 0xC0,  // 7#.q..U.
                /* 0778 */  0xF0, 0xFF, 0x3F, 0xAB, 0xC0, 0x1E, 0x21, 0xFC,  // ..?...!.
                /* 0780 */  0xDB, 0x83, 0xE7, 0xE5, 0x2B, 0xC3, 0xAB, 0x43,  // ....+..C
                /* 0788 */  0x02, 0x87, 0x1C, 0x21, 0x7A, 0x5C, 0x1E, 0x21,  // ...!z\.!
                /* 0790 */  0xE6, 0x7C, 0x84, 0x19, 0x22, 0xB8, 0xCE, 0x02,  // .|.."...
                /* 0798 */  0xE0, 0x18, 0x22, 0xF0, 0x39, 0xE0, 0x80, 0xE3,  // ..".9...
                /* 07A0 */  0xD2, 0xC4, 0x07, 0xEA, 0x03, 0x0E, 0xE0, 0xE0,  // ........
                /* 07A8 */  0x9A, 0x86, 0x3B, 0xE0, 0x80, 0xE3, 0x2C, 0xC0,  // ..;...,.
                /* 07B0 */  0xFE, 0xFF, 0x87, 0x1B, 0x58, 0x92, 0x4C, 0x1C,  // ....X.L.
                /* 07B8 */  0x46, 0x30, 0x22, 0x60, 0x50, 0x04, 0x04, 0x48,  // F0"`P..H
                /* 07C0 */  0x67, 0x01, 0x1F, 0x52, 0x00, 0x3E, 0x5C, 0x19,  // g..R.>\.
                /* 07C8 */  0x1E, 0x52, 0xB0, 0x27, 0x0D, 0x0F, 0x1C, 0x37,  // .R.'...7
                /* 07D0 */  0x0A, 0x0F, 0x1A, 0x17, 0x60, 0xD0, 0xF4, 0xC4,  // ....`...
                /* 07D8 */  0x01, 0xFF, 0x98, 0xE0, 0x33, 0x0A, 0x38, 0xC6,  // ....3.8.
                /* 07E0 */  0x0D, 0xBE, 0x55, 0x18, 0xF8, 0xFF, 0x7F, 0x60,  // ..U....`
                /* 07E8 */  0x98, 0xC3, 0x85, 0xC7, 0x72, 0x14, 0x41, 0x0F,  // ....r.A.
                /* 07F0 */  0x3C, 0xA8, 0xEF, 0x19, 0x67, 0xEE, 0x49, 0x1E,  // <...g.I.
                /* 07F8 */  0xA3, 0xA3, 0x1E, 0x4E, 0xE8, 0xC9, 0x0B, 0x77,  // ...N...w
                /* 0800 */  0xAE, 0xF2, 0x15, 0xE2, 0x28, 0x30, 0x70, 0xEF,  // ....(0p.
                /* 0808 */  0x52, 0x1E, 0x9F, 0x2F, 0x56, 0x86, 0xC7, 0x8C,  // R../V...
                /* 0810 */  0xF6, 0x3D, 0xE4, 0xAC, 0x23, 0x04, 0xC4, 0x5F,  // .=..#.._
                /* 0818 */  0xEA, 0xD8, 0x80, 0xC1, 0x72, 0x30, 0x00, 0x0E,  // ....r0..
                /* 0820 */  0x03, 0xC6, 0x27, 0x1A, 0xB0, 0xCE, 0x36, 0x78,  // ..'...6x
                /* 0828 */  0xE8, 0xD3, 0x62, 0x88, 0xC7, 0x17, 0xF6, 0xAD,  // ..b.....
                /* 0830 */  0xC2, 0x04, 0xD5, 0x83, 0xEA, 0x24, 0xE8, 0xA1,  // .....$..
                /* 0838 */  0x81, 0x03, 0xD0, 0x43, 0x83, 0x7F, 0x72, 0x21,  // ...C..r!
                /* 0840 */  0xF7, 0x57, 0x3A, 0x04, 0x6B, 0xC5, 0xD3, 0xBC,  // .W:.k...
                /* 0848 */  0x8F, 0x3C, 0xE6, 0xB9, 0x45, 0x79, 0x1B, 0x78,  // .<..Ey.x
                /* 0850 */  0x0E, 0xE0, 0xA7, 0x05, 0x0F, 0xC7, 0xC7, 0x02,  // ........
                /* 0858 */  0x8F, 0xD3, 0x97, 0xB0, 0x04, 0xEF, 0x35, 0x3E,  // ......5>
                /* 0860 */  0xD9, 0x3C, 0xB8, 0xB0, 0x64, 0x43, 0x40, 0x0D,  // .<..dC@.
                /* 0868 */  0xD6, 0x43, 0xC0, 0x4C, 0x35, 0x81, 0x93, 0x8C,  // .C.L5...
                /* 0870 */  0x00, 0x95, 0x01, 0x42, 0x37, 0x96, 0xD3, 0x7D,  // ...B7..}
                /* 0878 */  0x16, 0x09, 0x71, 0x9A, 0x8F, 0x32, 0x8F, 0x05,  // ..q..2..
                /* 0880 */  0x1E, 0xEB, 0x83, 0x81, 0xFF, 0xFF, 0x9A, 0x47,  // .......G
                /* 0888 */  0xA8, 0xFB, 0x9A, 0x67, 0xF6, 0x74, 0x80, 0x59,  // ...g.t.Y
                /* 0890 */  0x45, 0xB8, 0xF7, 0x9C, 0x37, 0x0C, 0xA3, 0x3D,  // E...7..=
                /* 0898 */  0x5B, 0xF8, 0x9A, 0xF1, 0xAC, 0x69, 0x84, 0x70,  // [....i.p
                /* 08A0 */  0xEC, 0x06, 0xE7, 0x91, 0x18, 0xE1, 0x05, 0x81,  // ........
                /* 08A8 */  0x9D, 0x18, 0x1E, 0x60, 0x8C, 0x73, 0xF2, 0x86,  // ...`.s..
                /* 08B0 */  0xF5, 0x85, 0x97, 0x81, 0x06, 0x33, 0xB6, 0x2F,  // .....3./
                /* 08B8 */  0x03, 0x6C, 0x54, 0xBE, 0x11, 0x81, 0x2F, 0xF9,  // .lT.../.
                /* 08C0 */  0xC5, 0x00, 0xCA, 0x2C, 0x7C, 0x3D, 0xF1, 0x41,  // ...,|=.A
                /* 08C8 */  0x89, 0x5D, 0x0C, 0x58, 0xCA, 0x8B, 0x01, 0xA8,  // .].X....
                /* 08D0 */  0x6E, 0x18, 0xBE, 0x18, 0xC0, 0xBF, 0x12, 0xBD,  // n.......
                /* 08D8 */  0x18, 0x80, 0xE1, 0xE2, 0xE4, 0x7B, 0x80, 0x3D,  // .....{.=
                /* 08E0 */  0xDC, 0x47, 0xE9, 0x38, 0x7D, 0xFB, 0x7B, 0x33,  // .G.8}.{3
                /* 08E8 */  0xF0, 0xD9, 0x80, 0xC1, 0x78, 0x86, 0x61, 0x8C,  // ....x.a.
                /* 08F0 */  0x11, 0xC6, 0xA3, 0x0C, 0x63, 0x82, 0xB9, 0x6F,  // ....c..o
                /* 08F8 */  0x07, 0xD0, 0x73, 0x0E, 0x03, 0x95, 0xF0, 0x76,  // ..s....v
                /* 0900 */  0x00, 0xE5, 0x1C, 0xD0, 0xE5, 0xD1, 0x84, 0x9E,  // ........
                /* 0908 */  0x02, 0x9E, 0x0E, 0x7C, 0x52, 0x34, 0x44, 0x5F,  // ...|R4D_
                /* 0910 */  0x63, 0x15, 0x4C, 0xA0, 0x88, 0x0F, 0x1A, 0x7C,  // c.L....|
                /* 0918 */  0x6A, 0x51, 0x7C, 0x2A, 0xF0, 0x5A, 0x9E, 0x9D,  // jQ|*.Z..
                /* 0920 */  0xC2, 0xC5, 0x39, 0x13, 0x4F, 0xD5, 0x70, 0x06,  // ..9.O.p.
                /* 0928 */  0x7A, 0xCD, 0x0D, 0xC7, 0xFE, 0xFF, 0x70, 0xF8,  // z.....p.
                /* 0930 */  0x53, 0xC1, 0x6B, 0x00, 0x3B, 0x48, 0x7A, 0x5A,  // S.k.;HzZ
                /* 0938 */  0x46, 0x84, 0x71, 0x48, 0x79, 0x64, 0xF0, 0x6D,  // F.qHyd.m
                /* 0940 */  0x31, 0x8E, 0x21, 0x1F, 0x22, 0x7D, 0x27, 0x30,  // 1.!."}'0
                /* 0948 */  0xE4, 0x43, 0xDE, 0xF3, 0x8E, 0x81, 0x5F, 0x11,  // .C...._.
                /* 0950 */  0xE2, 0x3C, 0x65, 0xF9, 0xCE, 0xE0, 0xCB, 0x02,  // .<e.....
                /* 0958 */  0xF8, 0x22, 0x5D, 0x16, 0xD0, 0xD0, 0x3E, 0xC9,  // ."]...>.
                /* 0960 */  0xF8, 0x82, 0x60, 0xD8, 0x13, 0x67, 0x01, 0xEE,  // ..`..g..
                /* 0968 */  0x0A, 0xA0, 0x02, 0xF5, 0x5D, 0x01, 0xFE, 0x85,  // ....]...
                /* 0970 */  0xE0, 0x5D, 0x01, 0x0C, 0xF3, 0xF2, 0xAD, 0x80,  // .]......
                /* 0978 */  0x6B, 0x3A, 0x94, 0xA0, 0xCF, 0x24, 0xBE, 0x2E,  // k:...$..
                /* 0980 */  0xE0, 0xA6, 0xC8, 0x52, 0x1D, 0x15, 0xA0, 0xA7,  // ...R....
                /* 0988 */  0x98, 0x04, 0xEA, 0x8E, 0xEE, 0xA3, 0x02, 0x8C,  // ........
                /* 0990 */  0x9B, 0xB2, 0x0F, 0xA8, 0xEC, 0xB4, 0xC0, 0xCE,  // ........
                /* 0998 */  0x42, 0xEC, 0x3A, 0x82, 0xBB, 0x92, 0x30, 0x94,  // B.:...0.
                /* 09A0 */  0x67, 0x03, 0x5F, 0xB2, 0xF8, 0xE1, 0x00, 0x06,  // g._.....
                /* 09A8 */  0xB8, 0x67, 0x71, 0x88, 0x11, 0x62, 0xB3, 0x03,  // .gq..b..
                /* 09B0 */  0xD7, 0xEB, 0xA4, 0xE1, 0x5E, 0x88, 0xD8, 0xFF,  // ....^...
                /* 09B8 */  0xFF, 0x64, 0x00, 0xC6, 0xA3, 0x36, 0x38, 0x4E,  // .d...68N
                /* 09C0 */  0x3A, 0xE1, 0x23, 0x3D, 0xB3, 0xF0, 0x93, 0x32,  // :.#=...2
                /* 09C8 */  0x60, 0xE2, 0xE4, 0x07, 0xC6, 0x93, 0x35, 0x8C,  // `.....5.
                /* 09D0 */  0x01, 0x70, 0x79, 0xAF, 0x2A, 0x03, 0xF9, 0x87,  // .py.*...
                /* 09D8 */  0x20, 0x41, 0x30, 0xA8, 0x53, 0x32, 0x70, 0x38,  //  A0.S2p8
                /* 09E0 */  0x8A, 0xE1, 0x4E, 0xC9, 0xF0, 0xA0, 0xF0, 0x87,  // ..N.....
                /* 09E8 */  0x01, 0xCC, 0x8D, 0xD0, 0xF7, 0x04, 0x43, 0xBD,  // ......C.
                /* 09F0 */  0x27, 0x1D, 0xC6, 0x23, 0xA1, 0x09, 0x7C, 0x5A,  // '..#..|Z
                /* 09F8 */  0x86, 0xF5, 0xFF, 0x3F, 0x2D, 0xF3, 0x73, 0x42,  // ...?-.sB
                /* 0A00 */  0xFC, 0xA7, 0x9C, 0xF7, 0x8B, 0x07, 0x65, 0x63,  // ......ec
                /* 0A08 */  0x44, 0x79, 0x55, 0xF6, 0x39, 0xD3, 0x28, 0xEC,  // DyU.9.(.
                /* 0A10 */  0x96, 0xFC, 0xE6, 0xF0, 0xAA, 0xEC, 0xD3, 0xF2,  // ........
                /* 0A18 */  0xB9, 0x45, 0x7A, 0x5F, 0xF6, 0xC8, 0x63, 0xC6,  // .Ez_..c.
                /* 0A20 */  0x89, 0x15, 0x24, 0xD0, 0xFB, 0x46, 0x94, 0xB0,  // ..$..F..
                /* 0A28 */  0x31, 0xC2, 0x05, 0x7A, 0x5A, 0x66, 0xC7, 0x76,  // 1..zZf.v
                /* 0A30 */  0x0F, 0xD9, 0x67, 0x05, 0xDC, 0xD9, 0x01, 0xEE,  // ..g.....
                /* 0A38 */  0xF4, 0xF8, 0xE9, 0x01, 0x70, 0x02, 0xF4, 0xF4,  // ....p...
                /* 0A40 */  0x00, 0xB6, 0xF3, 0x06, 0xDC, 0x03, 0x01, 0xE2,  // ........
                /* 0A48 */  0xF8, 0x8F, 0x0A, 0x7E, 0x65, 0xA1, 0x70, 0xFC,  // ...~e.p.
                /* 0A50 */  0xD8, 0xCE, 0x8F, 0x25, 0xB8, 0xC3, 0x81, 0x8F,  // ...%....
                /* 0A58 */  0x0C, 0x3E, 0x40, 0xE2, 0x86, 0xE2, 0x43, 0x05,  // .>@...C.
                /* 0A60 */  0xF2, 0x2C, 0x00, 0x8A, 0xD1, 0xB3, 0x11, 0xB0,  // .,......
                /* 0A68 */  0x1B, 0xCC, 0x4B, 0x4B, 0x94, 0xFF, 0xFF, 0x7B,  // ..KK...{
                /* 0A70 */  0x03, 0x3B, 0xA5, 0xE0, 0x0E, 0x02, 0xE0, 0x3B,  // .;.....;
                /* 0A78 */  0x06, 0x80, 0x77, 0x30, 0x5C, 0xD6, 0x98, 0x51,  // ..w0\..Q
                /* 0A80 */  0x42, 0x60, 0x34, 0x66, 0xDC, 0x21, 0x84, 0x9F,  // B`4f.!..
                /* 0A88 */  0x08, 0x70, 0x63, 0xF6, 0xB8, 0x3D, 0x66, 0xDC,  // .pc..=f.
                /* 0A90 */  0x71, 0x96, 0x8F, 0xEA, 0x29, 0x23, 0x94, 0x0F,  // q...)#..
                /* 0A98 */  0x1C, 0xEC, 0x9C, 0xF1, 0x46, 0xC0, 0x87, 0x0E,  // ....F...
                /* 0AA0 */  0x3C, 0x0E, 0x30, 0xB8, 0x23, 0x05, 0x18, 0x2F,  // <.0.#../
                /* 0AA8 */  0x07, 0x6C, 0xEC, 0xE0, 0x0E, 0x42, 0x4E, 0x81,  // .l...BN.
                /* 0AB0 */  0x2C, 0x1D, 0x46, 0x63, 0xC7, 0xC9, 0x06, 0xD2,  // ,.Fc....
                /* 0AB8 */  0x31, 0xC6, 0x87, 0x5C, 0x8F, 0x1D, 0x37, 0x58,  // 1..\..7X
                /* 0AC0 */  0x8F, 0x1D, 0x77, 0x7C, 0xC1, 0xFE, 0xFF, 0x8F,  // ..w|....
                /* 0AC8 */  0x2F, 0x60, 0x18, 0x03, 0x17, 0x3F, 0x0C, 0xF4,  // /`...?..
                /* 0AD0 */  0xCD, 0xCF, 0xA3, 0x33, 0xB8, 0x87, 0xED, 0x13,  // ...3....
                /* 0AD8 */  0x4C, 0x8C, 0x37, 0x98, 0x10, 0x8F, 0x2C, 0x2F,  // L.7...,/
                /* 0AE0 */  0x2D, 0x11, 0x1E, 0x5A, 0x7C, 0x73, 0x79, 0x69,  // -..Z|syi
                /* 0AE8 */  0xF1, 0x2D, 0xC6, 0x28, 0x21, 0x22, 0x1C, 0x4C,  // .-.(!".L
                /* 0AF0 */  0x9C, 0x27, 0x18, 0x23, 0x1C, 0x78, 0x14, 0x43,  // .'.#.x.C
                /* 0AF8 */  0x44, 0x38, 0x81, 0x10, 0x27, 0x7D, 0xB2, 0x41,  // D8..'}.A
                /* 0B00 */  0xC2, 0xC7, 0x08, 0x1B, 0x2D, 0xCA, 0x13, 0x0C,  // ....-...
                /* 0B08 */  0x1B, 0x0B, 0x3F, 0xAF, 0x78, 0xF0, 0xFC, 0xB4,  // ..?.x...
                /* 0B10 */  0xE6, 0xBB, 0xA0, 0x27, 0x73, 0x8E, 0x0F, 0x59,  // ...'s..Y
                /* 0B18 */  0x9E, 0xDA, 0xE3, 0xA4, 0x0F, 0xB3, 0xB8, 0x41,  // .......A
                /* 0B20 */  0x3D, 0x38, 0xB2, 0xBB, 0x8E, 0x8F, 0xD7, 0xD8,  // =8......
                /* 0B28 */  0x53, 0x90, 0x87, 0xC0, 0x4F, 0x04, 0xBE, 0x20,  // S...O.. 
                /* 0B30 */  0x7A, 0xB2, 0xBE, 0xEB, 0xB1, 0x7B, 0x99, 0x31,  // z....{.1
                /* 0B38 */  0xAA, 0x9F, 0x02, 0xEA, 0x98, 0x72, 0x06, 0xAF,  // .....r..
                /* 0B40 */  0x10, 0xEC, 0x9E, 0xE7, 0x43, 0xB6, 0xEF, 0x92,  // ....C...
                /* 0B48 */  0x6C, 0x14, 0xB8, 0x43, 0x82, 0xCF, 0x48, 0xFC,  // l..C..H.
                /* 0B50 */  0x54, 0xE1, 0x61, 0x78, 0x14, 0x30, 0x66, 0xF0,  // T.ax.0f.
                /* 0B58 */  0x8E, 0x70, 0x68, 0x21, 0x0E, 0xF8, 0x7D, 0x97,  // .ph!..}.
                /* 0B60 */  0x0D, 0x35, 0xC6, 0xE9, 0xF9, 0xFC, 0xC1, 0x06,  // .5......
                /* 0B68 */  0x01, 0x1F, 0xEA, 0x50, 0x3D, 0xCC, 0xA3, 0x7A,  // ...P=..z
                /* 0B70 */  0x29, 0x64, 0x38, 0x67, 0x07, 0x77, 0x10, 0xD8,  // )d8g.w..
                /* 0B78 */  0xE3, 0x87, 0x07, 0xC1, 0x6F, 0x96, 0x7C, 0x10,  // ....o.|.
                /* 0B80 */  0xEC, 0x7C, 0xF3, 0x06, 0x67, 0x90, 0xFF, 0xFF,  // .|..g...
                /* 0B88 */  0x31, 0xC0, 0x3E, 0x53, 0xF9, 0x68, 0x82, 0x38,  // 1.>S.h.8
                /* 0B90 */  0x02, 0xA2, 0xCF, 0x1F, 0x1E, 0xC3, 0x9B, 0x1C,  // ........
                /* 0B98 */  0x1F, 0x0E, 0xF6, 0xE8, 0x81, 0x3B, 0x89, 0xC0,  // .....;..
                /* 0BA0 */  0x3D, 0x76, 0x1D, 0xB4, 0xAF, 0x71, 0xBE, 0x68,  // =v...q.h
                /* 0BA8 */  0xC1, 0xB8, 0xEF, 0x3D, 0x8B, 0x80, 0x1F, 0xE3,  // ...=....
                /* 0BB0 */  0xB1, 0x05, 0x1C, 0x87, 0x12, 0x70, 0x07, 0x3B,  // .....p.;
                /* 0BB8 */  0xAE, 0x71, 0x08, 0x45, 0x81, 0xD1, 0xA1, 0x04,  // .q.E....
                /* 0BC0 */  0x17, 0x03, 0x48, 0x30, 0x8E, 0x71, 0x46, 0x43,  // ..H0.qFC
                /* 0BC8 */  0x5F, 0x22, 0x7D, 0x48, 0x83, 0x33, 0x68, 0xD8,  // _"}H.3h.
                /* 0BD0 */  0xF3, 0x7C, 0x42, 0xE1, 0xF6, 0x04, 0x28, 0x3A,  // .|B...(:
                /* 0BD8 */  0xA1, 0x80, 0x0C, 0xF7, 0x19, 0x04, 0x7B, 0x42,  // ......{B
                /* 0BE0 */  0xE0, 0x67, 0x10, 0xF6, 0xFF, 0x3F, 0x38, 0x7A,  // .g...?8z
                /* 0BE8 */  0xDC, 0xEF, 0x8D, 0x3E, 0x35, 0xB2, 0xB9, 0x3F,  // ...>5..?
                /* 0BF0 */  0x04, 0x9C, 0xC0, 0xB9, 0xB3, 0x53, 0x33, 0xEE,  // .....S3.
                /* 0BF8 */  0xCC, 0x80, 0x3D, 0x7F, 0x78, 0x08, 0xFC, 0x5C,  // ..=.x..\
                /* 0C00 */  0xE0, 0xE1, 0x7B, 0x08, 0xF8, 0xC1, 0x3F, 0x30,  // ..{...?0
                /* 0C08 */  0x1B, 0x1C, 0x8C, 0xA7, 0x08, 0x5F, 0x3B, 0x38,  // ....._;8
                /* 0C10 */  0x38, 0x3F, 0x0D, 0x18, 0x9C, 0xBF, 0x42, 0x7D,  // 8?....B}
                /* 0C18 */  0x9E, 0x67, 0xE0, 0xD8, 0x53, 0xAF, 0xEF, 0x1D,  // .g..S...
                /* 0C20 */  0x9E, 0xAF, 0x0F, 0x15, 0xF8, 0x9B, 0x9E, 0x0F,  // ........
                /* 0C28 */  0x15, 0xE0, 0x38, 0x3C, 0xF0, 0xC3, 0x0A, 0x1B,  // ..8<....
                /* 0C30 */  0xC2, 0xA3, 0x00, 0xFE, 0xD4, 0xE2, 0xE3, 0x5F,  // ......._
                /* 0C38 */  0x9C, 0xA7, 0x08, 0x76, 0x1B, 0xC1, 0x1E, 0x2E,  // ...v....
                /* 0C40 */  0x00, 0x47, 0xD1, 0xCE, 0x62, 0xA8, 0x30, 0x67,  // .G..b.0g
                /* 0C48 */  0x31, 0xF2, 0xFF, 0x3F, 0x47, 0xA1, 0xCE, 0x62,  // 1..?G..b
                /* 0C50 */  0xF4, 0x70, 0x01, 0xB8, 0x10, 0x7C, 0x3C, 0x00,  // .p...|<.
                /* 0C58 */  0xCD, 0x41, 0xE0, 0x71, 0xC1, 0x17, 0x82, 0x23,  // .A.q...#
                /* 0C60 */  0x39, 0x90, 0xA7, 0x03, 0xC0, 0xA7, 0x3C, 0x12,  // 9.....<.
                /* 0C68 */  0x7A, 0x3E, 0xB2, 0x20, 0x18, 0xD4, 0xF9, 0xC0,  // z>. ....
                /* 0C70 */  0x27, 0x14, 0x1F, 0x3B, 0xF8, 0xD9, 0xC0, 0x37,  // '..;...7
                /* 0C78 */  0x72, 0x0F, 0x95, 0x9F, 0x9A, 0x7D, 0xD2, 0xE6,  // r....}..
                /* 0C80 */  0xC1, 0x7F, 0xD2, 0xB2, 0x01, 0xA3, 0x40, 0xC3,  // ......@.
                /* 0C88 */  0x40, 0x8D, 0xC8, 0x47, 0xA4, 0xFF, 0xFF, 0x73,  // @..G...s
                /* 0C90 */  0x1B, 0x36, 0xC0, 0xD0, 0xE8, 0x39, 0x1C, 0xC6,  // .6...9..
                /* 0C98 */  0x01, 0xD7, 0xE7, 0x70, 0xEC, 0x80, 0x7C, 0x0E,  // ...p..|.
                /* 0CA0 */  0x87, 0x7F, 0x8E, 0x86, 0x3F, 0x36, 0x76, 0xBA,  // ....?6v.
                /* 0CA8 */  0xE7, 0x03, 0x83, 0x75, 0xFD, 0xC6, 0x0C, 0x0C,  // ...u....
                /* 0CB0 */  0x6C, 0xDF, 0x22, 0x0F, 0x0C, 0x38, 0xA2, 0x9E,  // l."..8..
                /* 0CB8 */  0x8D, 0xAF, 0x10, 0x1E, 0x18, 0xD8, 0x00, 0x3D,  // .......=
                /* 0CC0 */  0x30, 0xE0, 0x13, 0x0B, 0x42, 0x4E, 0x06, 0x86,  // 0...BN..
                /* 0CC8 */  0x3A, 0x65, 0x18, 0x39, 0xE6, 0x13, 0x87, 0x87,  // :e.9....
                /* 0CD0 */  0xE1, 0x43, 0x45, 0xD4, 0x67, 0x80, 0x47, 0x3C,  // .CE.g.G<
                /* 0CD8 */  0x36, 0x36, 0xF6, 0xFF, 0x1F, 0x1B, 0x58, 0x8E,  // 66....X.
                /* 0CE0 */  0x2D, 0x1E, 0x1B, 0xF8, 0x8F, 0xF0, 0xF8, 0xB1,  // -.......
                /* 0CE8 */  0xC1, 0x19, 0xCB, 0xA3, 0x89, 0x2F, 0x33, 0x47,  // ...../3G
                /* 0CF0 */  0x76, 0x1A, 0x67, 0xF6, 0x1A, 0xE2, 0xA3, 0xDD,  // v.g.....
                /* 0CF8 */  0xE3, 0xB7, 0xC7, 0x06, 0x2E, 0x0B, 0x63, 0x03,  // ......c.
                /* 0D00 */  0x4A, 0x21, 0xC7, 0x86, 0x3E, 0xA4, 0xF8, 0x14,  // J!..>...
                /* 0D08 */  0x60, 0xE3, 0xA8, 0x64, 0x1E, 0x3E, 0x5E, 0xF9,  // `..d.>^.
                /* 0D10 */  0xC4, 0x70, 0x74, 0x41, 0xDE, 0xD0, 0x7D, 0xB9,  // .ptA..}.
                /* 0D18 */  0xF0, 0x91, 0xC6, 0x60, 0xBE, 0xB4, 0xF8, 0x0C,  // ...`....
                /* 0D20 */  0xCA, 0x87, 0x08, 0x2E, 0x0D, 0x43, 0x04, 0x4A,  // .....C.J
                /* 0D28 */  0xA1, 0x86, 0x88, 0x1E, 0xCF, 0xFF, 0xFF, 0x11,  // ........
                /* 0D30 */  0xCC, 0x43, 0x64, 0x43, 0x03, 0xEF, 0x37, 0x46,  // .CdC..7F
                /* 0D38 */  0x43, 0x03, 0x42, 0xE1, 0x86, 0x86, 0x3E, 0xAC,  // C.B...>.
                /* 0D40 */  0xF9, 0x10, 0xC0, 0x20, 0x7C, 0x1B, 0x60, 0x57,  // ... |.`W
                /* 0D48 */  0x01, 0x5F, 0x85, 0x3C, 0xC0, 0x27, 0x51, 0x36,  // ._.<.'Q6
                /* 0D50 */  0x3C, 0xF0, 0x0D, 0xCA, 0xC3, 0x03, 0x3E, 0xE1,  // <.....>.
                /* 0D58 */  0x81, 0xBD, 0x0A, 0x0F, 0x8F, 0x9E, 0x95, 0x3C,  // .......<
                /* 0D60 */  0x3C, 0x78, 0x20, 0x8F, 0x11, 0xEC, 0x1C, 0xE2,  // <x .....
                /* 0D68 */  0xC1, 0x81, 0xC3, 0xC4, 0xE0, 0x40, 0x71, 0xF4,  // .....@q.
                /* 0D70 */  0xC7, 0x0D, 0x81, 0x5D, 0x66, 0x3D, 0x71, 0x7E,  // ...]f=q~
                /* 0D78 */  0x65, 0xF1, 0xA0, 0xF0, 0xFF, 0xFF, 0x23, 0x00,  // e.....#.
                /* 0D80 */  0xAC, 0xE3, 0x0C, 0xF8, 0x82, 0x1D, 0x0E, 0xD0,  // ........
                /* 0D88 */  0xC7, 0x44, 0x36, 0x86, 0x87, 0x88, 0x07, 0x57,  // .D6....W
                /* 0D90 */  0x0F, 0xC4, 0xD7, 0x8E, 0xD7, 0x62, 0xDC, 0xD1,  // .....b..
                /* 0D98 */  0x00, 0x5C, 0x2A, 0x8E, 0x06, 0x40, 0xE9, 0x60,  // .\*..@.`
                /* 0DA0 */  0x0B, 0x8E, 0x7B, 0x9A, 0x8F, 0x76, 0x98, 0x39,  // ..{..v.9
                /* 0DA8 */  0x7A, 0x00, 0xCF, 0x6F, 0x1E, 0x2D, 0x3F, 0xBF,  // z..o.-?.
                /* 0DB0 */  0x01, 0x8E, 0x82, 0x1E, 0x6C, 0xE9, 0xC0, 0x1D,  // ....l...
                /* 0DB8 */  0x0D, 0x06, 0x75, 0x7E, 0xC3, 0xFC, 0xFF, 0xCF,  // ..u~....
                /* 0DC0 */  0x6F, 0x60, 0x88, 0x00, 0xAE, 0x33, 0x8D, 0xCF,  // o`...3..
                /* 0DC8 */  0x2F, 0x70, 0x86, 0x7A, 0xD0, 0xBE, 0x26, 0x78,  // /p.z..&x
                /* 0DD0 */  0xD6, 0xBE, 0x71, 0xB1, 0x73, 0x02, 0xB8, 0x06,  // ..q.s...
                /* 0DD8 */  0xE4, 0x93, 0x0E, 0x70, 0x04, 0x3E, 0x89, 0x07,  // ...p.>..
                /* 0DE0 */  0xFC, 0x43, 0x03, 0xF3, 0xB0, 0x3C, 0x34, 0xE0,  // .C...<4.
                /* 0DE8 */  0x73, 0x34, 0xC0, 0x9D, 0x28, 0xC0, 0x73, 0x1B,  // s4..(.s.
                /* 0DF0 */  0xC1, 0x1D, 0x28, 0x80, 0xC5, 0xFF, 0xFF, 0x40,  // ..(....@
                /* 0DF8 */  0x01, 0xAC, 0x8E, 0xF8, 0x1E, 0x17, 0x87, 0xC6,  // ........
                /* 0E00 */  0x21, 0x3E, 0xA4, 0x9D, 0xB3, 0xCF, 0x5F, 0x67,  // !>...._g
                /* 0E08 */  0x8A, 0x3B, 0x8B, 0x80, 0xE1, 0x44, 0x8F, 0x78,  // .;...D.x
                /* 0E10 */  0xA7, 0x19, 0xC8, 0x0F, 0x0C, 0x09, 0x81, 0x41,  // .......A
                /* 0E18 */  0x9D, 0x80, 0x3C, 0x14, 0x1F, 0x0C, 0x38, 0xB0,  // ..<...8.
                /* 0E20 */  0x8F, 0x08, 0xEC, 0x5C, 0xC0, 0x0E, 0x50, 0x86,  // ...\..P.
                /* 0E28 */  0xE3, 0x67, 0x01, 0x9F, 0x12, 0x1E, 0x6A, 0x8E,  // .g....j.
                /* 0E30 */  0xE3, 0x71, 0xD3, 0x77, 0x33, 0x43, 0xB2, 0xAB,  // .q.w3C..
                /* 0E38 */  0xC1, 0xF3, 0x0F, 0xF6, 0xB4, 0x0B, 0xE7, 0x88,  // ........
                /* 0E40 */  0x0B, 0x2E, 0x02, 0x9F, 0x75, 0x3C, 0x0A, 0x7E,  // ....u<.~
                /* 0E48 */  0x7A, 0xF0, 0x1C, 0xDF, 0x18, 0x7C, 0x7A, 0x60,  // z....|z`
                /* 0E50 */  0xEE, 0x05, 0x98, 0x3B, 0x74, 0x0B, 0xE1, 0x98,  // ...;t...
                /* 0E58 */  0x5E, 0x1F, 0x62, 0x1C, 0xF5, 0x63, 0x43, 0x5B,  // ^.b..cC[
                /* 0E60 */  0x02, 0xB4, 0xA1, 0xE8, 0x0E, 0xF0, 0x32, 0x10,  // ......2.
                /* 0E68 */  0x25, 0xC4, 0x11, 0x44, 0x6A, 0x0D, 0x45, 0x33,  // %..Dj.E3
                /* 0E70 */  0x8F, 0x14, 0x25, 0x60, 0x3C, 0xC3, 0x34, 0x36,  // ..%`<.46
                /* 0E78 */  0x19, 0x41, 0xC6, 0x08, 0x1D, 0x27, 0x58, 0x94,  // .A...'X.
                /* 0E80 */  0x68, 0xAF, 0x00, 0xED, 0x8F, 0x96, 0xAD, 0x58,  // h......X
                /* 0E88 */  0x63, 0x71, 0xA4, 0x93, 0x25, 0x7A, 0xD8, 0x3E,  // cq..%z.>
                /* 0E90 */  0x66, 0xE3, 0x4F, 0xAB, 0x98, 0xFF, 0x3F, 0xC1,  // f.O...?.
                /* 0E98 */  0xAB, 0x8A, 0x0F, 0x0A, 0x3E, 0x00, 0xE0, 0x5D,  // ....>..]
                /* 0EA0 */  0x02, 0xEA, 0xEA, 0xE8, 0x71, 0xFB, 0xBC, 0x01,  // ....q...
                /* 0EA8 */  0xFE, 0xEB, 0x05, 0x96, 0xA0, 0xFC, 0x41, 0xA0,  // ......A.
                /* 0EB0 */  0x46, 0x66, 0x68, 0x8F, 0xF3, 0x6D, 0xC6, 0x90,  // Ffh..m..
                /* 0EB8 */  0x4F, 0x4E, 0x26, 0xB0, 0xD8, 0x13, 0x2A, 0xD0,  // ON&...*.
                /* 0EC0 */  0x18, 0xFC, 0xD3, 0x86, 0xAF, 0xED, 0x9E, 0xAF,  // ........
                /* 0EC8 */  0xCF, 0x71, 0x00, 0x1F, 0xFE, 0xFF, 0xE7, 0x38,  // .q.....8
                /* 0ED0 */  0xC0, 0xD0, 0x70, 0x70, 0x47, 0x1F, 0xB8, 0x57,  // ..ppG..W
                /* 0ED8 */  0x12, 0x7E, 0xF8, 0x01, 0x9C, 0x01, 0x3D, 0xFC,  // .~....=.
                /* 0EE0 */  0x80, 0x7D, 0xA8, 0xB8, 0x21, 0xF0, 0x08, 0x2B,  // .}..!..+
                /* 0EE8 */  0xA2, 0x87, 0x01, 0x8B, 0x86, 0x41, 0x9D, 0xD7,  // .....A..
                /* 0EF0 */  0xB0, 0xFF, 0xFF, 0xF3, 0x1A, 0x6C, 0x71, 0xE0,  // .....lq.
                /* 0EF8 */  0x3A, 0xA8, 0xFA, 0x6C, 0x0C, 0x67, 0x50, 0xA7,  // :..l.gP.
                /* 0F00 */  0xDD, 0xFB, 0x5D, 0x81, 0x5C, 0x44, 0x3C, 0xE8,  // ..].\D<.
                /* 0F08 */  0xF3, 0x79, 0x76, 0x60, 0x07, 0x36, 0xE0, 0x3F,  // .yv`.6.?
                /* 0F10 */  0x36, 0x38, 0x37, 0x80, 0xA7, 0xE8, 0x08, 0xC7,  // 687.....
                /* 0F18 */  0x06, 0xF6, 0x13, 0x1B, 0x70, 0x3A, 0xDB, 0xC1,  // ....p:..
                /* 0F20 */  0xB9, 0x42, 0xB1, 0xDB, 0x3E, 0x6E, 0x68, 0x60,  // .B..>nh`
                /* 0F28 */  0xB3, 0x31, 0x34, 0x90, 0xFD, 0xFF, 0x0F, 0x9F,  // .14.....
                /* 0F30 */  0xC0, 0xEB, 0xD0, 0xC5, 0x2F, 0x15, 0xCF, 0x5F,  // ..../.._
                /* 0F38 */  0xFC, 0x70, 0x07, 0x38, 0x97, 0x76, 0xB2, 0x43,  // .p.8.v.C
                /* 0F40 */  0x89, 0x39, 0xDC, 0x01, 0x52, 0xFE, 0xFF, 0x87,  // .9..R...
                /* 0F48 */  0x3B, 0x70, 0xDD, 0xE5, 0xDE, 0x19, 0x5E, 0x1A,  // ;p....^.
                /* 0F50 */  0x3C, 0xA7, 0x77, 0x3B, 0x63, 0xBC, 0xD4, 0x19,  // <.w;c...
                /* 0F58 */  0x21, 0x0A, 0xBB, 0x0D, 0x44, 0xB3, 0xB7, 0xC3,  // !...D...
                /* 0F60 */  0x1D, 0x39, 0xE1, 0x71, 0xCC, 0x48, 0x4F, 0x7A,  // .9.q.HOz
                /* 0F68 */  0xC1, 0x22, 0x45, 0x3C, 0x9C, 0x28, 0x21, 0x82,  // ."E<.(!.
                /* 0F70 */  0xBD, 0x4E, 0x3C, 0xE5, 0x3D, 0xDC, 0x31, 0x21,  // .N<.=.1!
                /* 0F78 */  0x87, 0x3B, 0xA0, 0xE3, 0xFA, 0x70, 0x07, 0x54,  // .;...p.T
                /* 0F80 */  0x4E, 0x54, 0xF8, 0xC3, 0x1D, 0x60, 0xF6, 0xFF,  // NT...`..
                /* 0F88 */  0x7F, 0xB8, 0x03, 0x18, 0x75, 0x46, 0xC3, 0x1D,  // ....uF..
                /* 0F90 */  0xEE, 0xC0, 0x76, 0xFA, 0x01, 0xCE, 0xFF, 0xFF,  // ..v.....
                /* 0F98 */  0xD3, 0x0F, 0xF0, 0x1E, 0x2B, 0x8C, 0x31, 0xF0,  // ....+.1.
                /* 0FA0 */  0x68, 0x4B, 0xA2, 0x40, 0x0E, 0x03, 0x83, 0x22,  // hK.@..."
                /* 0FA8 */  0x70, 0x90, 0x43, 0x1D, 0x0D, 0x76, 0x7A, 0x81,  // p.C..vz.
                /* 0FB0 */  0x32, 0x97, 0x03, 0x3D, 0x85, 0x67, 0x04, 0x1F,  // 2..=.g..
                /* 0FB8 */  0xC0, 0xC0, 0x7E, 0xAA, 0x03, 0x0E, 0xA7, 0x06,  // ..~.....
                /* 0FC0 */  0x7C, 0xA0, 0x13, 0x0A, 0x7A, 0x14, 0x3E, 0x9B,  // |...z.>.
                /* 0FC8 */  0x80, 0xF7, 0x48, 0x07, 0x6C, 0xFE, 0xFF, 0x67,  // ..H.l..g
                /* 0FD0 */  0x13, 0xF6, 0x6A, 0xF4, 0xD9, 0x04, 0xC7, 0x62,  // ..j....b
                /* 0FD8 */  0xD4, 0x37, 0x88, 0x43, 0x7C, 0xE9, 0xF0, 0xB9,  // .7.C|...
                /* 0FE0 */  0xF1, 0x9D, 0xC6, 0x97, 0x00, 0xCC, 0xF5, 0xC3,  // ........
                /* 0FE8 */  0x04, 0x63, 0x42, 0xE8, 0x93, 0xE5, 0x53, 0x1D,  // .cB...S.
                /* 0FF0 */  0x70, 0x3A, 0x9C, 0xC0, 0x1B, 0x3D, 0xEE, 0xB4,  // p:...=..
                /* 0FF8 */  0xE0, 0xE1, 0x70, 0x70, 0xCF, 0xE6, 0x59, 0xE2,  // ..pp..Y.
                /* 1000 */  0x89, 0xC8, 0x3A, 0x4E, 0x27, 0x40, 0xED, 0x80,  // ..:N'@..
                /* 1008 */  0x81, 0x99, 0x41, 0xF8, 0x87, 0x10, 0x76, 0xFA,  // ..A...v.
                /* 1010 */  0xF4, 0x91, 0xC9, 0x73, 0x7F, 0x37, 0xF2, 0xE9,  // ...s.7..
                /* 1018 */  0x04, 0xF0, 0xF5, 0xFF, 0x3F, 0xEA, 0x01, 0x0B,  // ....?...
                /* 1020 */  0x89, 0x1A, 0xCE, 0x79, 0x18, 0x51, 0x30, 0xA8,  // ...y.Q0.
                /* 1028 */  0xA3, 0x1E, 0x60, 0xED, 0xA2, 0x67, 0x63, 0x08,  // ..`..gc.
                /* 1030 */  0xBA, 0x08, 0x9C, 0x41, 0x88, 0xC7, 0xBB, 0x57,  // ...A...W
                /* 1038 */  0xBC, 0x48, 0xBE, 0x03, 0xC4, 0x79, 0xD4, 0x33,  // .H...y.3
                /* 1040 */  0xD8, 0xDB, 0xC7, 0x83, 0x44, 0x94, 0x38, 0x8F,  // ....D.8.
                /* 1048 */  0x7A, 0x1E, 0x7D, 0x28, 0x4F, 0x3E, 0xD4, 0xE9,  // z.}(O>..
                /* 1050 */  0xC7, 0x0A, 0x1B, 0xE8, 0x89, 0xEF, 0x45, 0x2F,  // ......E/
                /* 1058 */  0xA4, 0x11, 0x1E, 0xF5, 0x98, 0xA0, 0x97, 0x87,  // ........
                /* 1060 */  0x0E, 0x57, 0x3E, 0xEA, 0x01, 0x56, 0xFE, 0xFF,  // .W>..V..
                /* 1068 */  0x47, 0x3D, 0x80, 0xFF, 0xFF, 0xFF, 0xA3, 0x1E,  // G=......
                /* 1070 */  0x98, 0x4F, 0x4F, 0x80, 0xFF, 0x63, 0x0D, 0xEE,  // .OO..c..
                /* 1078 */  0xA8, 0x08, 0xB6, 0xF3, 0x13, 0xE0, 0xE2, 0xFF,  // ........
                /* 1080 */  0x7F, 0x7E, 0x02, 0xD3, 0xD0, 0x7D, 0x7E, 0x02,  // .~...}~.
                /* 1088 */  0xF3, 0x68, 0x61, 0x1E, 0x10, 0x10, 0x67, 0x45,  // .ha...gE
                /* 1090 */  0x54, 0xF8, 0x87, 0x8C, 0xE1, 0x50, 0xC1, 0x81,  // T....P..
                /* 1098 */  0xF4, 0x8B, 0xF2, 0x11, 0x10, 0xB8, 0x1C, 0x15,  // ........
                /* 10A0 */  0x81, 0xC3, 0x99, 0x05, 0x2F, 0xE4, 0xD4, 0x81,  // ..../...
                /* 10A8 */  0x1E, 0x8F, 0x41, 0x5F, 0x39, 0x7C, 0x25, 0xE0,  // ..A_9|%.
                /* 10B0 */  0x47, 0x0E, 0x16, 0xFA, 0xC8, 0x01, 0xAA, 0xC3,  // G.......
                /* 10B8 */  0x22, 0xF8, 0x8E, 0x1C, 0xE0, 0xB8, 0x5E, 0x05,  // ".....^.
                /* 10C0 */  0xE6, 0xFF, 0x7F, 0x60, 0x76, 0x3B, 0x78, 0xFD,  // ...`v;x.
                /* 10C8 */  0xF4, 0x24, 0x1E, 0xA3, 0x8E, 0x33, 0x44, 0xE1,  // .$...3D.
                /* 10D0 */  0x98, 0xE4, 0x60, 0x10, 0xE9, 0x1D, 0x8C, 0x0D,  // ..`.....
                /* 10D8 */  0xF0, 0xE5, 0xC5, 0x87, 0x2A, 0x1F, 0x03, 0x81,  // ....*...
                /* 10E0 */  0x21, 0xC4, 0xD9, 0xF0, 0xD3, 0x85, 0x31, 0x4F,  // !.....1O
                /* 10E8 */  0x87, 0x1F, 0x03, 0x01, 0xEB, 0x52, 0xCF, 0x80,  // .....R..
                /* 10F0 */  0x28, 0x71, 0xC7, 0x40, 0x20, 0xF5, 0xFF, 0x3F,  // (q.@ ..?
                /* 10F8 */  0x06, 0x02, 0xD7, 0x4B, 0xA0, 0xC7, 0x7C, 0xC6,  // ...K..|.
                /* 1100 */  0x6F, 0x7E, 0x4F, 0x7E, 0x51, 0x6A, 0xBB, 0xFE,  // o~O~Qj..
                /* 1108 */  0xE9, 0x6E, 0x60, 0xAC, 0x87, 0x80, 0x27, 0x40,  // .n`...'@
                /* 1110 */  0xDF, 0xFF, 0x7C, 0xAC, 0x88, 0x12, 0x30, 0x4A,  // ..|...0J
                /* 1118 */  0xAC, 0x17, 0x41, 0x63, 0xC6, 0x08, 0xF6, 0x0E,  // ..Ac....
                /* 1120 */  0x18, 0xF3, 0x91, 0xD0, 0x23, 0x8C, 0x16, 0xDC,  // ....#...
                /* 1128 */  0x40, 0x8F, 0x81, 0x4C, 0xD8, 0x31, 0x10, 0x20,  // @..L.1. 
                /* 1130 */  0xD1, 0xFF, 0xFF, 0x18, 0x08, 0x30, 0xF2, 0x04,  // .....0..
                /* 1138 */  0x05, 0x6C, 0xFF, 0xFF, 0x27, 0x28, 0xC0, 0xD0,  // .l..'(..
                /* 1140 */  0x51, 0x10, 0xCC, 0x67, 0x28, 0xC0, 0xDA, 0x51,  // Q..g(..Q
                /* 1148 */  0x10, 0xEC, 0xA3, 0x85, 0x39, 0x0A, 0x1E, 0xF3,  // ....9...
                /* 1150 */  0xE5, 0x61, 0x20, 0x1A, 0x4C, 0xC2, 0xFF, 0xFF,  // .a .L...
                /* 1158 */  0x28, 0x88, 0x0D, 0x05, 0xA4, 0x73, 0x87, 0x43,  // (....s.C
                /* 1160 */  0x9D, 0x5E, 0xD0, 0x07, 0x05, 0x0F, 0xFB, 0xA9,  // .^......
                /* 1168 */  0xC0, 0x93, 0x38, 0x55, 0x5F, 0x0B, 0x8E, 0xE2,  // ..8U_...
                /* 1170 */  0x09, 0xC0, 0x87, 0x41, 0xE0, 0x3F, 0x34, 0x58,  // ...A.?4X
                /* 1178 */  0x93, 0x28, 0x7E, 0x68, 0xA0, 0x3E, 0x7B, 0x80,  // .(~h.>{.
                /* 1180 */  0x6F, 0x68, 0xE0, 0x88, 0x7A, 0xC6, 0x41, 0x9F,  // oh..z.A.
                /* 1188 */  0x88, 0x7C, 0x36, 0x88, 0xF9, 0xE6, 0x11, 0xE1,  // .|6.....
                /* 1190 */  0xC9, 0xC3, 0xD7, 0x07, 0x76, 0xF2, 0xF4, 0xA9,  // ....v...
                /* 1198 */  0x29, 0x50, 0x94, 0xF7, 0x0D, 0x1E, 0xE7, 0x94,  // )P......
                /* 11A0 */  0x03, 0xAA, 0xC3, 0x2F, 0x38, 0x0E, 0xBC, 0x30,  // .../8..0
                /* 11A8 */  0xFE, 0xFF, 0x07, 0x5E, 0x76, 0x9C, 0xF2, 0xB1,  // ...^v...
                /* 11B0 */  0x04, 0x7C, 0x67, 0x52, 0x38, 0x37, 0x17, 0xDF,  // .|gR87..
                /* 11B8 */  0xF1, 0xD8, 0x69, 0x00, 0x6C, 0x07, 0x62, 0x9F,  // ..i.l.b.
                /* 11C0 */  0x06, 0x80, 0x4F, 0xAC, 0x81, 0xA1, 0x8F, 0x2A,  // ..O....*
                /* 11C8 */  0x46, 0xED, 0x7D, 0x12, 0x9A, 0x18, 0xBB, 0x8E,  // F.}.....
                /* 11D0 */  0xBC, 0xA4, 0xF8, 0x7A, 0xF2, 0xAC, 0x05, 0x3E,  // ...z...>
                /* 11D8 */  0x1F, 0x63, 0x03, 0x4A, 0x27, 0x30, 0x7E, 0xF4,  // .c.J'0~.
                /* 11E0 */  0x04, 0x13, 0xCC, 0xC1, 0xBC, 0x8A, 0x7B, 0x90,  // ......{.
                /* 11E8 */  0x4F, 0x42, 0xEC, 0x94, 0x03, 0xDE, 0xFF, 0xFF,  // OB......
                /* 11F0 */  0xC1, 0x13, 0xB0, 0x27, 0xE2, 0xD4, 0x89, 0x8A,  // ...'....
                /* 11F8 */  0xFD, 0xE6, 0xF2, 0xC1, 0x13, 0x90, 0x77, 0x67,  // ......wg
                /* 1200 */  0x30, 0xC2, 0xF9, 0x87, 0x78, 0x80, 0x08, 0xF1,  // 0...x...
                /* 1208 */  0xCC, 0x69, 0x90, 0x38, 0x41, 0x5E, 0x06, 0x1E,  // .i.8A^..
                /* 1210 */  0x3C, 0x7D, 0xEF, 0x8C, 0xF3, 0xEC, 0x19, 0xE5,  // <}......
                /* 1218 */  0xCD, 0xD3, 0x08, 0x47, 0x1F, 0xCF, 0x40, 0xEF,  // ...G..@.
                /* 1220 */  0x9C, 0x21, 0xDE, 0x3A, 0x9F, 0x41, 0x5F, 0x3D,  // .!.:.A_=
                /* 1228 */  0x8D, 0x16, 0x2B, 0xF8, 0x31, 0x3E, 0x78, 0xB2,  // ..+.1>x.
                /* 1230 */  0xC8, 0x67, 0x24, 0x7A, 0xF0, 0x84, 0xFD, 0xFF,  // .g$z....
                /* 1238 */  0x3F, 0x78, 0x02, 0xFC, 0xFF, 0xFF, 0x1F, 0x3C,  // ?x.....<
                /* 1240 */  0x01, 0x63, 0x67, 0x30, 0xC0, 0xE9, 0xD1, 0x1F,  // .cg0....
                /* 1248 */  0x3C, 0x27, 0x4D, 0x18, 0x47, 0x26, 0xF0, 0xFF,  // <'M.G&..
                /* 1250 */  0xFF, 0x8F, 0x4C, 0x80, 0xAB, 0xB1, 0xC2, 0x18,  // ..L.....
                /* 1258 */  0x03, 0x8F, 0x78, 0x5E, 0x42, 0x85, 0x3A, 0x32,  // ..x^B.:2
                /* 1260 */  0x01, 0x02, 0x67, 0x74, 0xFA, 0xAF, 0xFE, 0xBE,  // ..gt....
                /* 1268 */  0x25, 0x3D, 0xAB, 0x1C, 0xC2, 0xA3, 0xBF, 0x41,  // %=.....A
                /* 1270 */  0x8C, 0x70, 0xDC, 0x8F, 0x4C, 0x3E, 0x2F, 0x3D,  // .p..L>/=
                /* 1278 */  0x2D, 0x3D, 0x37, 0xF9, 0xAE, 0xF4, 0xB8, 0x14,  // -=7.....
                /* 1280 */  0x2C, 0x44, 0x94, 0x60, 0x8F, 0xFD, 0xBE, 0x3A,  // ,D.`...:
                /* 1288 */  0xF9, 0xFE, 0x64, 0x0C, 0x9F, 0x9A, 0x82, 0x84,  // ..d.....
                /* 1290 */  0x7B, 0x64, 0x62, 0x81, 0x8E, 0x4C, 0x90, 0xFF,  // {db..L..
                /* 1298 */  0xFF, 0x47, 0x26, 0x80, 0xFF, 0xFF, 0xFF, 0x23,  // .G&....#
                /* 12A0 */  0x13, 0x60, 0xEE, 0x40, 0x0B, 0xE7, 0x00, 0xF3,  // .`.@....
                /* 12A8 */  0x92, 0xC0, 0x8E, 0x05, 0xE0, 0x1B, 0x8C, 0x8F,  // ........
                /* 12B0 */  0x05, 0xC0, 0x47, 0xDE, 0x29, 0x15, 0x84, 0x27,  // ..G.)..'
                /* 12B8 */  0x9E, 0x23, 0x7D, 0x89, 0x61, 0x27, 0x24, 0x60,  // .#}.a'$`
                /* 12C0 */  0xFA, 0xFF, 0x3F, 0x21, 0x01, 0x26, 0xF4, 0xA8,  // ..?!.&..
                /* 12C8 */  0x00, 0x61, 0x47, 0x01, 0x4B, 0x3A, 0x1F, 0x09,  // .aG.K:..
                /* 12D0 */  0x86, 0xB3, 0xF8, 0x84, 0xE0, 0x73, 0x01, 0x3F,  // .....s.?
                /* 12D8 */  0x21, 0x78, 0x04, 0x15, 0x8F, 0x93, 0x9E, 0x82,  // !x......
                /* 12E0 */  0x7C, 0xD0, 0x67, 0x27, 0x03, 0x47, 0x1F, 0x24,  // |.g'.G.$
                /* 12E8 */  0x1D, 0x19, 0xEE, 0x3C, 0x00, 0xB6, 0xC3, 0x11,  // ...<....
                /* 12F0 */  0xAC, 0x43, 0x01, 0xE0, 0x26, 0xF3, 0xB2, 0x34,  // .C..&..4
                /* 12F8 */  0x72, 0xE7, 0x05, 0x91, 0x8D, 0x23, 0x0B, 0xE5,  // r....#..
                /* 1300 */  0xB0, 0x2A, 0x20, 0x9D, 0xF9, 0x7D, 0xC8, 0xF2,  // .* ..}..
                /* 1308 */  0xE5, 0xE3, 0x54, 0x4E, 0x15, 0x7F, 0x2C, 0xB1,  // ..TN..,.
                /* 1310 */  0x0A, 0x11, 0xFF, 0x7F, 0x78, 0x76, 0x08, 0x72,  // ....xv.r
                /* 1318 */  0x7E, 0x0F, 0x10, 0xE3, 0x3D, 0x5B, 0x34, 0x1A,  // ~...=[4.
                /* 1320 */  0x1F, 0x9F, 0x38, 0x9C, 0x41, 0xCC, 0x26, 0x01,  // ..8.A.&.
                /* 1328 */  0xD9, 0x0E, 0x50, 0x68, 0x25, 0x20, 0x1A, 0x03,  // ..Ph% ..
                /* 1330 */  0x3F, 0x3E, 0x61, 0x82, 0xDC, 0x63, 0xE8, 0xCC,  // ?>a..c..
                /* 1338 */  0x7D, 0x39, 0xE0, 0x2F, 0x63, 0x9F, 0x3B, 0x0C,  // }9./c.;.
                /* 1340 */  0xEE, 0x3B, 0x09, 0x38, 0x66, 0x63, 0x35, 0xA0,  // .;.8fc5.
                /* 1348 */  0xA8, 0x01, 0x18, 0x0D, 0x73, 0x0E, 0x78, 0x74,  // ....s.xt
                /* 1350 */  0x01, 0x57, 0xAE, 0x9B, 0x0B, 0xFA, 0x25, 0xE1,  // .W....%.
                /* 1358 */  0x9B, 0x0B, 0x66, 0x6E, 0xC0, 0x61, 0xFC, 0x9E,  // ..fn.a..
                /* 1360 */  0x1B, 0x2C, 0x34, 0xCF, 0x0D, 0xFE, 0xED, 0x05,  // .,4.....
                /* 1368 */  0x1B, 0x6D, 0x6E, 0x68, 0x64, 0x76, 0xB3, 0x37,  // .mnhdv.7
                /* 1370 */  0xC2, 0x2B, 0x82, 0x0F, 0x1F, 0x1E, 0x1D, 0x70,  // .+.....p
                /* 1378 */  0x00, 0xF4, 0xE8, 0xD8, 0xFF, 0x7F, 0x74, 0x78,  // ......tx
                /* 1380 */  0x24, 0x8F, 0x0E, 0x6C, 0x09, 0x47, 0x87, 0xD6,  // $..l.G..
                /* 1388 */  0x03, 0x22, 0x97, 0x27, 0x37, 0x72, 0x32, 0x39,  // .".'7r29
                /* 1390 */  0xBD, 0x93, 0x79, 0x53, 0xF1, 0xE9, 0x22, 0x48,  // ..yS.."H
                /* 1398 */  0xA0, 0x38, 0xD1, 0x9F, 0x4D, 0x3C, 0x41, 0xE0,  // .8..M<A.
                /* 13A0 */  0x30, 0x00, 0x4F, 0x10, 0x16, 0x9A, 0x27, 0x08,  // 0.O...'.
                /* 13A8 */  0xB6, 0x88, 0xD7, 0x0C, 0xF4, 0xFD, 0xC3, 0xC8,  // ........
                /* 13B0 */  0x21, 0x4F, 0xEF, 0x89, 0xC9, 0xA0, 0xBE, 0xDD,  // !O......
                /* 13B8 */  0xC0, 0x18, 0x21, 0x70, 0x78, 0x5A, 0x7A, 0x84,  // ..!pxZz.
                /* 13C0 */  0xB0, 0xD0, 0x7C, 0xD4, 0x00, 0x5B, 0xBC, 0x11,  // ..|..[..
                /* 13C8 */  0xA2, 0x87, 0xE5, 0x5B, 0xC9, 0xF9, 0x9D, 0xDC,  // ...[....
                /* 13D0 */  0xF1, 0xC1, 0xFE, 0xFF, 0x8F, 0x0F, 0xBC, 0xC0,  // ........
                /* 13D8 */  0x1E, 0x1F, 0x2C, 0x14, 0x8F, 0x0F, 0x6C, 0xFA,  // ..,...l.
                /* 13E0 */  0xEE, 0x46, 0xA0, 0x00, 0xF2, 0x49, 0xC8, 0xE7,  // .F...I..
                /* 13E8 */  0x93, 0x97, 0x21, 0x36, 0x86, 0x57, 0x29, 0xA3,  // ..!6.W).
                /* 13F0 */  0x19, 0x9D, 0xEB, 0xDB, 0x92, 0xCE, 0x37, 0x5C,  // ......7\
                /* 13F8 */  0x11, 0x8C, 0xCE, 0x2E, 0x06, 0xF1, 0x8D, 0xC4,  // ........
                /* 1400 */  0x69, 0x29, 0x74, 0x0C, 0xC1, 0xE3, 0x9F, 0xF7,  // i)t.....
                /* 1408 */  0x19, 0xBD, 0x29, 0x78, 0xB6, 0x3E, 0xE8, 0x08,  // ..)x.>..
                /* 1410 */  0x52, 0xC7, 0x01, 0x1F, 0x36, 0xF1, 0xB7, 0x0B,  // R...6...
                /* 1418 */  0x3E, 0x0D, 0x5F, 0xA4, 0x9F, 0x05, 0x31, 0xD3,  // >._...1.
                /* 1420 */  0xB6, 0xD6, 0x41, 0xEB, 0x0A, 0x13, 0xF0, 0x14,  // ..A.....
                /* 1428 */  0x5E, 0x85, 0x8C, 0xE7, 0x33, 0x32, 0x1B, 0x8F,  // ^...32..
                /* 1430 */  0x4F, 0xD0, 0x3E, 0x18, 0xF9, 0x84, 0xE5, 0x43,  // O.>....C
                /* 1438 */  0x69, 0x82, 0x57, 0x09, 0x1F, 0x26, 0x9E, 0x94,  // i.W..&..
                /* 1440 */  0xD8, 0x05, 0x35, 0xC1, 0x63, 0x6A, 0x82, 0xC7,  // ..5.cj..
                /* 1448 */  0xD3, 0x04, 0x0F, 0xA7, 0x09, 0x9E, 0x51, 0x43,  // ......QC
                /* 1450 */  0x1A, 0x95, 0xC1, 0x1A, 0xE2, 0x09, 0x8E, 0x65,  // .......e
                /* 1458 */  0x5D, 0x82, 0x06, 0xC3, 0x47, 0xE7, 0xC1, 0x60,  // ]...G..`
                /* 1460 */  0xEE, 0x47, 0x1E, 0x9D, 0x00, 0x35, 0x16, 0x9E,  // .G...5..
                /* 1468 */  0x8A, 0x44, 0x47, 0x6E, 0x9F, 0xAE, 0xDE, 0xAE,  // .DGn....
                /* 1470 */  0x7C, 0x59, 0xF0, 0x85, 0xC1, 0x17, 0x2A, 0x2F,  // |Y....*/
                /* 1478 */  0xE0, 0xC1, 0x1B, 0xC6, 0xF9, 0xC8, 0x87, 0x2A,  // .......*
                /* 1480 */  0xFF, 0xFF, 0xA1, 0xE2, 0x04, 0x7E, 0x25, 0x78,  // .....~%x
                /* 1488 */  0xD7, 0x0A, 0x11, 0xCC, 0xB0, 0x8F, 0x01, 0x8F,  // ........
                /* 1490 */  0x1B, 0x46, 0xF5, 0x79, 0xD7, 0x58, 0x8F, 0x49,  // .F.y.X.I
                /* 1498 */  0x1E, 0x31, 0xBF, 0x4F, 0x1D, 0x50, 0xA4, 0xE7,  // .1.O.P..
                /* 14A0 */  0x1F, 0x4F, 0xC0, 0x97, 0x2C, 0xDF, 0x4A, 0x4F,  // .O..,.JO
                /* 14A8 */  0xCA, 0xE7, 0x5B, 0xA3, 0xBF, 0x4A, 0xF8, 0x52,  // ..[..J.R
                /* 14B0 */  0x66, 0x64, 0x9F, 0xC0, 0xD8, 0xFD, 0x94, 0x0D,  // fd......
                /* 14B8 */  0x8A, 0x23, 0x3E, 0x38, 0x3C, 0x84, 0x78, 0x2A,  // .#>8<.x*
                /* 14C0 */  0xEC, 0xFE, 0x84, 0x01, 0x8B, 0x79, 0x04, 0x0F,  // .....y..
                /* 14C8 */  0x83, 0xFC, 0xE8, 0x72, 0x44, 0x16, 0x7F, 0x73,  // ...rD..s
                /* 14D0 */  0x24, 0x33, 0x38, 0x43, 0x83, 0x62, 0x06, 0xC9,  // $38C.b..
                /* 14D8 */  0x87, 0x74, 0x52, 0x3E, 0xF4, 0x30, 0x3C, 0xDC,  // .tR>.0<.
                /* 14E0 */  0x78, 0xD8, 0x60, 0x7D, 0x8C, 0x64, 0x53, 0x60,  // x.`}.dS`
                /* 14E8 */  0x03, 0xF2, 0x64, 0x3C, 0x1B, 0x76, 0xE8, 0xC0,  // ..d<.v..
                /* 14F0 */  0x0F, 0xCF, 0x87, 0x26, 0x5F, 0x96, 0x3D, 0x1E,  // ...&_.=.
                /* 14F8 */  0x8F, 0x84, 0x5F, 0x12, 0xCE, 0xD0, 0xC0, 0x70,  // .._....p
                /* 1500 */  0x6E, 0x04, 0x0F, 0x6E, 0x0C, 0xD9, 0xA7, 0x0E,  // n..n....
                /* 1508 */  0x83, 0x44, 0x7B, 0x82, 0xF0, 0x94, 0x30, 0xA7,  // .D{...0.
                /* 1510 */  0x23, 0x0F, 0xCC, 0x43, 0xF0, 0x84, 0x60, 0x5C,  // #..C..`\
                /* 1518 */  0xDF, 0xF1, 0xC7, 0x0F, 0x76, 0xD9, 0xC3, 0xDC,  // ....v...
                /* 1520 */  0x24, 0xC1, 0x75, 0x91, 0xF0, 0xF9, 0x03, 0xCC,  // $.u.....
                /* 1528 */  0x04, 0xFF, 0xFF, 0xF0, 0xFC, 0x0E, 0xEA, 0x53,  // .......S
                /* 1530 */  0x8B, 0x65, 0x8D, 0x0B, 0x75, 0x70, 0xF1, 0x1D,  // .e..up..
                /* 1538 */  0x95, 0x8D, 0x99, 0xDD, 0xF8, 0xCE, 0xF2, 0x00,  // ........
                /* 1540 */  0x5F, 0xC9, 0x30, 0xB0, 0xBE, 0x7A, 0x70, 0x58,  // _.0..zpX
                /* 1548 */  0xA3, 0x85, 0x7D, 0x88, 0x78, 0x6F, 0xF0, 0x41,  // ..}.xo.A
                /* 1550 */  0x0F, 0x77, 0x75, 0x06, 0x0B, 0x20, 0xFE, 0x2E,  // .wu.. ..
                /* 1558 */  0xF0, 0xE0, 0xE2, 0x09, 0x18, 0x90, 0xC5, 0x59,  // .......Y
                /* 1560 */  0x15, 0xBD, 0xA5, 0x3B, 0x00, 0x0C, 0xEA, 0xA2,  // ...;....
                /* 1568 */  0x0E, 0x58, 0xBB, 0x9E, 0xFB, 0xB4, 0xF2, 0xA6,  // .X......
                /* 1570 */  0xF2, 0x50, 0xF0, 0xC6, 0x12, 0x21, 0xC8, 0x13,  // .P...!..
                /* 1578 */  0xFA, 0x3B, 0x42, 0x84, 0x50, 0x81, 0x5E, 0xD4,  // .;B.P.^.
                /* 1580 */  0x8D, 0x17, 0xF4, 0xF9, 0x2B, 0x4A, 0x9C, 0x28,  // ....+J.(
                /* 1588 */  0x11, 0x42, 0x19, 0xE3, 0x5C, 0x9E, 0x0E, 0x5E,  // .B..\..^
                /* 1590 */  0x5D, 0xC2, 0x3D, 0x26, 0x04, 0x7E, 0x72, 0x78,  // ].=&.~rx
                /* 1598 */  0x52, 0x37, 0xC2, 0x31, 0xBE, 0xA8, 0x33, 0xF1,  // R7.1..3.
                /* 15A0 */  0xD7, 0x1B, 0xDD, 0x86, 0x7C, 0x51, 0x07, 0xE7,  // ....|Q..
                /* 15A8 */  0xFF, 0xFF, 0xA2, 0x0E, 0xB8, 0x1E, 0x86, 0x6F,  // .......o
                /* 15B0 */  0xAD, 0xE0, 0xB8, 0x26, 0xF0, 0x7B, 0x2B, 0xE0,  // ...&.{+.
                /* 15B8 */  0x70, 0x1A, 0xEF, 0xC6, 0xB0, 0xFF, 0xFF, 0x77,  // p......w
                /* 15C0 */  0x63, 0xD8, 0xC3, 0x85, 0x3D, 0x0C, 0x9E, 0xEC,  // c...=...
                /* 15C8 */  0x65, 0x40, 0x0F, 0x05, 0x16, 0x75, 0x3D, 0x06,  // e@...u=.
                /* 15D0 */  0xED, 0x0D, 0xDF, 0xE3, 0xF4, 0x99, 0x04, 0x77,  // .......w
                /* 15D8 */  0x3D, 0x06, 0x0B, 0xC2, 0x73, 0x8D, 0x0F, 0x10,  // =...s...
                /* 15E0 */  0x3E, 0x49, 0x78, 0x6A, 0x70, 0x0E, 0x06, 0x80,  // >Ixjp...
                /* 15E8 */  0x1B, 0xED, 0x8F, 0x5A, 0x9D, 0x35, 0x1C, 0xE0,  // ...Z.5..
                /* 15F0 */  0x3B, 0xA7, 0xFB, 0x31, 0x2E, 0xE6, 0x33, 0x47,  // ;..1..3G
                /* 15F8 */  0xD3, 0x64, 0x43, 0x85, 0x45, 0xE0, 0x58, 0x17,  // .dC.E.X.
                /* 1600 */  0x63, 0x3A, 0x00, 0xDF, 0x8C, 0xAD, 0x9D, 0x44,  // c:.....D
                /* 1608 */  0x17, 0x3E, 0xAE, 0x16, 0x46, 0x70, 0x06, 0xF1,  // .>..Fp..
                /* 1610 */  0xC9, 0xC7, 0x47, 0x5E, 0x9F, 0x5B, 0x70, 0x47,  // ..G^.[pG
                /* 1618 */  0x5E, 0x9F, 0x59, 0xFC, 0xFF, 0xBF, 0x1D, 0x03,  // ^.Y.....
                /* 1620 */  0x56, 0x82, 0xCD, 0x0D, 0x7D, 0x5F, 0xF1, 0x79,  // V...}_.y
                /* 1628 */  0x0F, 0x73, 0x3C, 0x06, 0x1C, 0x0C, 0x0E, 0x7B,  // .s<....{
                /* 1630 */  0xEE, 0x86, 0x73, 0x1C, 0x05, 0x56, 0xD7, 0x63,  // ..s..V.c
                /* 1638 */  0xB0, 0x1F, 0x47, 0x61, 0xFC, 0xFF, 0x8F, 0xA3,  // ..Ga....
                /* 1640 */  0xC0, 0x40, 0xD3, 0x6D, 0x02, 0xA5, 0xE2, 0x36,  // .@.m...6
                /* 1648 */  0x41, 0x41, 0x7C, 0x03, 0x70, 0x42, 0x1A, 0x1D,  // AA|.pB..
                /* 1650 */  0x47, 0xE1, 0xE7, 0x81, 0xD4, 0x71, 0x14, 0xFE,  // G....q..
                /* 1658 */  0x84, 0x1E, 0x47, 0xC1, 0x70, 0xA7, 0xF3, 0x78,  // ..G.p..x
                /* 1660 */  0x7C, 0xB6, 0x37, 0xAB, 0x8F, 0xA3, 0x70, 0xF3,  // |.7...p.
                /* 1668 */  0x0E, 0x02, 0x75, 0x0C, 0x85, 0x93, 0x6F, 0x0C,  // ..u...o.
                /* 1670 */  0xA8, 0x64, 0x10, 0x3A, 0x86, 0x02, 0xB6, 0x0E,  // .d.:....
                /* 1678 */  0x92, 0xE0, 0xFA, 0xFF, 0x1F, 0x24, 0x01, 0x1E,  // .....$..
                /* 1680 */  0xE4, 0x5E, 0x97, 0x0E, 0x44, 0xFC, 0xF4, 0x68,  // .^..D..h
                /* 1688 */  0x75, 0x07, 0x22, 0x04, 0xC6, 0x33, 0xDF, 0xE3,  // u."..3..
                /* 1690 */  0x87, 0x67, 0xE3, 0xA3, 0x80, 0x8F, 0x51, 0x9E,  // .g....Q.
                /* 1698 */  0xF9, 0x19, 0x3D, 0xD7, 0x32, 0x2D, 0x27, 0x22,  // ..=.2-'"
                /* 16A0 */  0x94, 0x0A, 0x18, 0x05, 0xA6, 0xD1, 0x9D, 0x83,  // ........
                /* 16A8 */  0x47, 0xBC, 0x17, 0x53, 0x10, 0x8F, 0xD6, 0x37,  // G..S...7
                /* 16B0 */  0x17, 0x60, 0x7A, 0x26, 0x02, 0xD3, 0xFF, 0xFF,  // .`z&....
                /* 16B8 */  0xE6, 0x02, 0x86, 0x90, 0xB3, 0x43, 0xCF, 0xDB,  // .....C..
                /* 16C0 */  0xD3, 0x66, 0xC7, 0x5F, 0xDC, 0xB4, 0x61, 0x9C,  // .f._..a.
                /* 16C8 */  0x8C, 0x00, 0x1F, 0x77, 0x1D, 0x80, 0x15, 0xFF,  // ...w....
                /* 16D0 */  0xFF, 0xBB, 0x0E, 0xC0, 0xC2, 0xFB, 0x83, 0xEF,  // ........
                /* 16D8 */  0x3A, 0xC0, 0x35, 0xD2, 0x05, 0x1C, 0xF1, 0xFF,  // :.5.....
                /* 16E0 */  0x87, 0x18, 0xE2, 0x0E, 0x0E, 0x08, 0x3C, 0x6E,  // ......<n
                /* 16E8 */  0xBC, 0x44, 0xBC, 0x76, 0xFB, 0x12, 0xEE, 0x33,  // .D.v...3
                /* 16F0 */  0xC1, 0x29, 0x3C, 0x7C, 0x1F, 0x56, 0x9C, 0xF7,  // .)<|.V..
                /* 16F8 */  0x8D, 0x10, 0xEF, 0xE0, 0x3E, 0x7C, 0xFB, 0x0E,  // ....>|..
                /* 1700 */  0x6E, 0xBC, 0x48, 0x01, 0xA3, 0x45, 0x09, 0xF6,  // n.H..E..
                /* 1708 */  0x10, 0x1E, 0x22, 0x68, 0xA4, 0x10, 0x01, 0x43,  // .."h...C
                /* 1710 */  0xBC, 0x83, 0xC7, 0x0A, 0x17, 0xFD, 0x1D, 0x9C,  // ........
                /* 1718 */  0x05, 0xB8, 0x83, 0x03, 0xB2, 0xFF, 0xFF, 0x77,  // .......w
                /* 1720 */  0x70, 0x30, 0x5F, 0xA3, 0x71, 0x77, 0x70, 0xB0,  // p0_.qwp.
                /* 1728 */  0x5D, 0x8E, 0x01, 0x7B, 0x82, 0x2F, 0xE1, 0x20,  // ]..{./. 
                /* 1730 */  0x1F, 0x2F, 0x18, 0xC6, 0xC1, 0x95, 0x93, 0xD0,  // ./......
                /* 1738 */  0x63, 0x81, 0xB5, 0xC2, 0xA0, 0x6E, 0xE1, 0xE0,  // c....n..
                /* 1740 */  0xD2, 0x04, 0xAE, 0xAB, 0xB2, 0x0F, 0x35, 0x3E,  // ......5>
                /* 1748 */  0x04, 0xE3, 0xCF, 0x17, 0xEC, 0xFF, 0x7F, 0x72,  // .......r
                /* 1750 */  0x60, 0x01, 0x86, 0x4C, 0x4F, 0x65, 0x30, 0xAE,  // `..LOe0.
                /* 1758 */  0x29, 0x3E, 0x95, 0x61, 0xEE, 0x0E, 0x1E, 0x90,  // )>.a....
                /* 1760 */  0x8F, 0x18, 0xC0, 0x67, 0x15, 0x1E, 0x18, 0xEE,  // ...g....
                /* 1768 */  0xB4, 0xE0, 0x9B, 0x92, 0x41, 0xCF, 0x31, 0xA8,  // ....A.1.
                /* 1770 */  0x8F, 0x3C, 0x27, 0xEF, 0x7B, 0xC2, 0xE3, 0x84,  // .<'.{...
                /* 1778 */  0xA3, 0x9E, 0x83, 0xE8, 0xD8, 0xC0, 0x71, 0xDC,  // ......q.
                /* 1780 */  0x00, 0xC7, 0xE1, 0x06, 0x77, 0xCE, 0x63, 0xE3,  // ....w.c.
                /* 1788 */  0xC2, 0xC0, 0x3D, 0x17, 0x78, 0x18, 0xBE, 0xE9,  // ..=.x...
                /* 1790 */  0x78, 0x44, 0x98, 0xF1, 0x3F, 0xEA, 0x19, 0x21,  // xD..?..!
                /* 1798 */  0x20, 0xFE, 0x62, 0xC4, 0x06, 0x0C, 0xC6, 0x5B,  //  .b....[
                /* 17A0 */  0x9B, 0xAF, 0x6F, 0xB8, 0x01, 0xFB, 0xEA, 0xE0,  // ..o.....
                /* 17A8 */  0x0B, 0x86, 0x4F, 0x60, 0x46, 0x7F, 0x81, 0x79,  // ..O`F..y
                /* 17B0 */  0x12, 0xF3, 0xB1, 0x81, 0x5C, 0xE0, 0xE8, 0x80,  // ....\...
                /* 17B8 */  0xC1, 0x01, 0xE8, 0x01, 0xC3, 0xFE, 0xFF, 0x5F,  // ......._
                /* 17C0 */  0xEC, 0x7C, 0x97, 0x03, 0xC3, 0x55, 0xD0, 0xC7,  // .|...U..
                /* 17C8 */  0x05, 0x1F, 0x7B, 0xAC, 0xE8, 0x2E, 0x87, 0xBE,  // ..{.....
                /* 17D0 */  0xC9, 0x19, 0x26, 0x8E, 0x21, 0xDE, 0xC0, 0xD8,  // ..&.!...
                /* 17D8 */  0x5D, 0x82, 0x1C, 0xE6, 0xA0, 0xDE, 0x25, 0x3C,  // ].....%<
                /* 17E0 */  0x07, 0x7E, 0xB6, 0xF0, 0x09, 0xCE, 0x37, 0x9F,  // .~....7.
                /* 17E8 */  0x10, 0xA7, 0xFA, 0x68, 0xF5, 0x1E, 0xE0, 0xA3,  // ...h....
                /* 17F0 */  0xC7, 0x7B, 0x97, 0xCF, 0x4E, 0xEC, 0x22, 0xE0,  // .{..N.".
                /* 17F8 */  0x23, 0x97, 0x71, 0x3C, 0x4D, 0x5F, 0x01, 0x3D,  // #.q<M_.=
                /* 1800 */  0x64, 0x83, 0xBD, 0x6A, 0xF8, 0x04, 0xE6, 0xA3,  // d..j....
                /* 1808 */  0x1B, 0xEE, 0x18, 0xE5, 0x99, 0x78, 0xFA, 0xBE,  // .....x..
                /* 1810 */  0x83, 0xB0, 0x23, 0xC9, 0x51, 0x87, 0xBA, 0xA6,  // ..#.Q...
                /* 1818 */  0x47, 0x94, 0x13, 0x3A, 0x10, 0xDF, 0xDA, 0xC0,  // G..:....
                /* 1820 */  0x19, 0xED, 0xFE, 0x81, 0xDE, 0xA6, 0x47, 0x86,  // ......G.
                /* 1828 */  0x39, 0x1A, 0xC0, 0xBA, 0x84, 0x80, 0xEB, 0x8E,  // 9.......
                /* 1830 */  0xE1, 0x4B, 0x08, 0xF0, 0x09, 0x7A, 0x89, 0x40,  // .K...z.@
                /* 1838 */  0x5F, 0x33, 0x3C, 0xBA, 0x47, 0x00, 0xCC, 0x15,  // _3<.G...
                /* 1840 */  0x83, 0xA1, 0xFC, 0xFF, 0xCF, 0xFA, 0x61, 0xC3,  // ......a.
                /* 1848 */  0xD7, 0x00, 0x76, 0x2F, 0x70, 0x98, 0x7B, 0x04,  // ..v/p.{.
                /* 1850 */  0xA8, 0x40, 0x3D, 0x3C, 0xF8, 0x6A, 0xEF, 0x11,  // .@=<.j..
                /* 1858 */  0xA0, 0x38, 0x59, 0xFA, 0xD0, 0xE0, 0x81, 0x5A,  // .8Y....Z
                /* 1860 */  0xD5, 0x19, 0x13, 0xCA, 0x11, 0x93, 0x43, 0x45,  // ......CE
                /* 1868 */  0x63, 0xB7, 0x02, 0x76, 0xBB, 0xF4, 0x4D, 0x02,  // c..v..M.
                /* 1870 */  0x6E, 0x9E, 0x59, 0xA0, 0x92, 0xDC, 0x24, 0xA0,  // n.Y...$.
                /* 1878 */  0xC3, 0x74, 0x79, 0x99, 0xA1, 0xF3, 0x3F, 0x70,  // .ty...?p
                /* 1880 */  0xDF, 0xEA, 0x3C, 0x42, 0x1F, 0x22, 0x18, 0xCA,  // ..<B."..
                /* 1888 */  0x7B, 0x9E, 0x4F, 0x61, 0xFC, 0x0C, 0xE1, 0x03,  // {.Oa....
                /* 1890 */  0x26, 0x3B, 0x53, 0xF0, 0xB3, 0x26, 0xEE, 0x0E,  // &;S..&..
                /* 1898 */  0x60, 0x94, 0x37, 0x4F, 0x4F, 0x80, 0x9D, 0x3F,  // `.7OO..?
                /* 18A0 */  0x8D, 0xFC, 0x6E, 0xF0, 0x2E, 0xE0, 0xE9, 0xFB,  // ..n.....
                /* 18A8 */  0x5E, 0xC4, 0x4F, 0x14, 0xE0, 0x0B, 0x76, 0xA7,  // ^.O...v.
                /* 18B0 */  0x83, 0x02, 0x7D, 0x42, 0x1E, 0x91, 0x51, 0x7D,  // ..}B..Q}
                /* 18B8 */  0x44, 0xE0, 0x97, 0x24, 0xB0, 0xFD, 0xFF, 0x47,  // D..$...G
                /* 18C0 */  0xE6, 0x23, 0x89, 0x0F, 0x14, 0x40, 0xE8, 0x5E,  // .#...@.^
                /* 18C8 */  0x80, 0x3A, 0x7D, 0xF0, 0xC3, 0xB3, 0x2F, 0xA8,  // .:}.../.
                /* 18D0 */  0xC6, 0x7C, 0xB7, 0x7A, 0x84, 0xF3, 0xE4, 0x30,  // .|.z...0
                /* 18D8 */  0x97, 0x03, 0x16, 0xE7, 0x9A, 0x04, 0xAA, 0xE3,  // ........
                /* 18E0 */  0x2E, 0x1F, 0x1D, 0xDC, 0x6B, 0x2B, 0x7E, 0x70,  // ....k+~p
                /* 18E8 */  0xEF, 0x2C, 0xEF, 0x7C, 0x86, 0xF2, 0x20, 0xC1,  // .,.|.. .
                /* 18F0 */  0x77, 0x6D, 0x05, 0xC7, 0x55, 0x0D, 0xC6, 0xB1,  // wm..U...
                /* 18F8 */  0x85, 0x5F, 0xF2, 0x00, 0x33, 0xFF, 0xFF, 0x61,  // ._..3..a
                /* 1900 */  0xE2, 0x04, 0xFF, 0x3D, 0x0C, 0x44, 0x25, 0xC2,  // ...=.D%.
                /* 1908 */  0xA0, 0x08, 0x2C, 0xEF, 0xDE, 0x4A, 0xE1, 0x0F,  // ..,..J..
                /* 1910 */  0x19, 0x8C, 0x37, 0x05, 0x3E, 0x69, 0xEC, 0xA8,  // ..7.>i..
                /* 1918 */  0x01, 0x3B, 0x43, 0xC5, 0xDD, 0x14, 0xC1, 0x3A,  // .;C....:
                /* 1920 */  0x55, 0xCC, 0x10, 0x78, 0xB0, 0x07, 0x80, 0xCF,  // U..x....
                /* 1928 */  0x57, 0x3E, 0x03, 0x28, 0x0A, 0x0C, 0xEA, 0xD0,  // W>.(....
                /* 1930 */  0x0E, 0xE7, 0x36, 0x0C, 0x3C, 0xFF, 0xFF, 0xB7,  // ..6.<...
                /* 1938 */  0x61, 0xB8, 0x23, 0xC6, 0x5D, 0x0A, 0xE1, 0x4E,  // a.#.]..N
                /* 1940 */  0xF9, 0x1D, 0x25, 0xF6, 0x73, 0x39, 0x9B, 0x2E,  // ..%.s9..
                /* 1948 */  0xEE, 0x6A, 0xEE, 0xD3, 0x09, 0xBB, 0x20, 0xC3,  // .j.... .
                /* 1950 */  0x38, 0x0B, 0x3C, 0x02, 0xBC, 0x9A, 0xF3, 0x0B,  // 8.<.....
                /* 1958 */  0xF2, 0x0B, 0xF1, 0x0B, 0xC1, 0x1B, 0xB2, 0x6F,  // .......o
                /* 1960 */  0x4A, 0xCF, 0x06, 0x2F, 0x3B, 0x31, 0xDE, 0x8D,  // J../;1..
                /* 1968 */  0x7D, 0x4A, 0xF6, 0x79, 0xE7, 0x05, 0xD9, 0x18,  // }J.y....
                /* 1970 */  0x47, 0x13, 0x31, 0xCA, 0xB9, 0x3D, 0x0C, 0xBC,  // G.1..=..
                /* 1978 */  0x26, 0x1B, 0xE5, 0xFD, 0xE4, 0x85, 0x20, 0x62,  // &..... b
                /* 1980 */  0x34, 0x43, 0x04, 0x8D, 0x11, 0xE8, 0x7D, 0xD9,  // 4C....}.
                /* 1988 */  0x78, 0x2F, 0xC8, 0x4C, 0xE0, 0x5B, 0x41, 0x07,  // x/.L.[A.
                /* 1990 */  0x17, 0x5F, 0x90, 0x01, 0x7E, 0x9C, 0x8C, 0xFC,  // ._..~...
                /* 1998 */  0xFF, 0x3F, 0x19, 0x01, 0x2E, 0x4F, 0x1C, 0xB8,  // .?...O..
                /* 19A0 */  0x4B, 0x35, 0xF8, 0x4E, 0x36, 0x80, 0xB3, 0xA1,  // K5.N6...
                /* 19A8 */  0xFB, 0x64, 0x03, 0xEE, 0xD1, 0xFA, 0xFF, 0x3F,  // .d.....?
                /* 19B0 */  0x5A, 0x38, 0x47, 0x13, 0xC4, 0xC9, 0x86, 0x02,  // Z8G.....
                /* 19B8 */  0x39, 0xF8, 0xBA, 0x28, 0x1C, 0x0F, 0x7D, 0x12,  // 9..(..}.
                /* 19C0 */  0xA1, 0x47, 0x27, 0x1F, 0x25, 0x71, 0x67, 0x06,  // .G'.%qg.
                /* 19C8 */  0x4F, 0xE4, 0x9D, 0xC5, 0xA3, 0x78, 0x19, 0xF4,  // O....x..
                /* 19D0 */  0xBD, 0xE0, 0x44, 0x5E, 0x1F, 0x2C, 0xE7, 0x18,  // ..D^.,..
                /* 19D8 */  0x09, 0xAA, 0x91, 0xF8, 0xF8, 0x00, 0xFF, 0xFA,  // ........
                /* 19E0 */  0xE2, 0x63, 0x24, 0x7C, 0x3E, 0xFF, 0xB0, 0x3C,  // .c$|>..<
                /* 19E8 */  0x18, 0x43, 0xFA, 0x14, 0xC9, 0x41, 0x9E, 0x5D,  // .C...A.]
                /* 19F0 */  0x1E, 0x43, 0xF8, 0x05, 0x12, 0xEE, 0x69, 0xE6,  // .C....i.
                /* 19F8 */  0x00, 0x30, 0xB2, 0x2E, 0x8F, 0xE8, 0xB3, 0x23,  // .0.....#
                /* 1A00 */  0xC7, 0x88, 0xEB, 0x8B, 0xA2, 0xAF, 0xC0, 0x3E,  // .......>
                /* 1A08 */  0x08, 0x9C, 0xCF, 0x73, 0x22, 0x58, 0x47, 0xCD,  // ...s"XG.
                /* 1A10 */  0x8F, 0x36, 0x7C, 0xFC, 0x1C, 0xFC, 0xAD, 0xE0,  // .6|.....
                /* 1A18 */  0x81, 0xD2, 0xC7, 0xA2, 0x10, 0x8F, 0x48, 0xFC,  // ......H.
                /* 1A20 */  0x9C, 0x08, 0x2E, 0x13, 0x67, 0x00, 0xE8, 0xFF,  // ....g...
                /* 1A28 */  0xFF, 0xD3, 0x0D, 0x58, 0x0E, 0xBD, 0x30, 0x4E,  // ...X..0N
                /* 1A30 */  0x0B, 0xB8, 0x81, 0xF8, 0x4C, 0x89, 0x9D, 0xF2,  // ....L...
                /* 1A38 */  0x89, 0xB0, 0x73, 0x09, 0x66, 0x74, 0xE0, 0xBA,  // ..s.ft..
                /* 1A40 */  0xDC, 0x7B, 0x74, 0xE0, 0x3F, 0x09, 0xE0, 0xB1,  // .{t.?...
                /* 1A48 */  0x1E, 0xEF, 0xC0, 0x77, 0x52, 0xF7, 0xDD, 0xC4,  // ...wR...
                /* 1A50 */  0x17, 0x19, 0x1F, 0x8A, 0x9E, 0xEF, 0x00, 0xAF,  // ........
                /* 1A58 */  0xFF, 0xFF, 0xF3, 0x1D, 0x78, 0xC2, 0x1D, 0xEE,  // ....x...
                /* 1A60 */  0x50, 0x71, 0xCE, 0x77, 0x00, 0x35, 0xCE, 0xD6,  // Pq.w.5..
                /* 1A68 */  0xCF, 0x77, 0x60, 0x17, 0x79, 0xBE, 0x03, 0xBA,  // .w`.y...
                /* 1A70 */  0xFF, 0xFF, 0xF3, 0x1D, 0xC0, 0xC3, 0x33, 0x1A,  // ......3.
                /* 1A78 */  0xEE, 0x7C, 0x07, 0xB6, 0xA3, 0x0D, 0xD8, 0xFF,  // .|......
                /* 1A80 */  0xFF, 0x47, 0x1B, 0xE0, 0x3E, 0x8D, 0x47, 0x1B,  // .G..>.G.
                /* 1A88 */  0x70, 0x0F, 0x17, 0xF6, 0x30, 0xB8, 0x42, 0x9B,  // p...0.B.
                /* 1A90 */  0x3E, 0x35, 0x1A, 0xB5, 0x6A, 0x50, 0xA6, 0x46,  // >5..jP.F
                /* 1A98 */  0x99, 0x06, 0xB5, 0xFA, 0x54, 0x6A, 0xCC, 0x98,  // ....Tj..
                /* 1AA0 */  0xB2, 0xD3, 0x8D, 0x02, 0x3E, 0x2A, 0x34, 0x36,  // ....>*46
                /* 1AA8 */  0xCB, 0xA3, 0x10, 0x88, 0xC5, 0xBC, 0x1A, 0x04,  // ........
                /* 1AB0 */  0xE2, 0xB0, 0x20, 0x34, 0xD2, 0x2B, 0x47, 0x20,  // .. 4.+G 
                /* 1AB8 */  0x96, 0xFC, 0xEC, 0x17, 0x88, 0xE5, 0xBE, 0x19,  // ........
                /* 1AC0 */  0x04, 0xE2, 0x80, 0x6F, 0x30, 0x81, 0x93, 0x87,  // ...o0...
                /* 1AC8 */  0x95, 0xC0, 0xC9, 0xBB, 0x41, 0x20, 0x8E, 0x0C,  // ....A ..
                /* 1AD0 */  0x42, 0x85, 0xEA, 0x00, 0x61, 0x31, 0x41, 0x68,  // B...a1Ah
                /* 1AD8 */  0x28, 0x1F, 0x20, 0x4C, 0xFA, 0x23, 0x41, 0x80,  // (. L.#A.
                /* 1AE0 */  0xC4, 0x08, 0x08, 0x0B, 0xF7, 0xFE, 0x12, 0x88,  // ........
                /* 1AE8 */  0xA5, 0xBD, 0x27, 0x04, 0x62, 0x21, 0x56, 0x40,  // ..'.b!V@
                /* 1AF0 */  0x58, 0x5C, 0x10, 0x1A, 0x4E, 0x0B, 0x08, 0x93,  // X\..N...
                /* 1AF8 */  0x64, 0x06, 0x84, 0x05, 0x02, 0xA1, 0xF2, 0xD5,  // d.......
                /* 1B00 */  0x80, 0x30, 0x91, 0x6E, 0x00, 0xE9, 0xEA, 0x05,  // .0.n....
                /* 1B08 */  0xE2, 0x20, 0x7A, 0x40, 0x98, 0x0C, 0x3F, 0x20,  // . z@..? 
                /* 1B10 */  0x2C, 0x34, 0x08, 0x8D, 0xF6, 0xC0, 0x10, 0x20,  // ,4..... 
                /* 1B18 */  0x31, 0x04, 0xC2, 0xE2, 0x3B, 0x02, 0x61, 0xE2,  // 1...;.a.
                /* 1B20 */  0x5F, 0x45, 0x02, 0x71, 0x7E, 0x4B, 0x10, 0xFF,  // _E.q~K..
                /* 1B28 */  0xFF, 0x9B, 0xD2, 0x10, 0x6B, 0x02, 0x62, 0x1A,  // ....k.b.
                /* 1B30 */  0x3C, 0x01, 0x31, 0x45, 0x20, 0x02, 0x72, 0xEC,  // <.1E .r.
                /* 1B38 */  0xA7, 0x87, 0x80, 0xAC, 0xC1, 0x14, 0x10, 0x8B,  // ........
                /* 1B40 */  0x0E, 0x22, 0x20, 0x0B, 0x51, 0x05, 0xC4, 0xF2,  // ." .Q...
                /* 1B48 */  0xBA, 0x02, 0x62, 0xE1, 0x41, 0x04, 0xE4, 0xCC,  // ..b.A...
                /* 1B50 */  0x2F, 0x3F, 0x01, 0x59, 0xC1, 0x4B, 0xE7, 0x21,  // /?.Y.K.!
                /* 1B58 */  0x80, 0xBD, 0x21, 0x02, 0x91, 0xE4, 0x20, 0x02,  // ..!... .
                /* 1B60 */  0x72, 0x60, 0x5F, 0x40, 0x2C, 0x3E, 0x88, 0x80,  // r`_@,>..
                /* 1B68 */  0x9C, 0xF5, 0x51, 0x28, 0x20, 0x07, 0x07, 0xD1,  // ..Q( ...
                /* 1B70 */  0x20, 0xC8, 0xD7, 0x4C, 0x40, 0x4E, 0x0F, 0x22,  //  ..L@N."
                /* 1B78 */  0x20, 0xF2, 0x09, 0x0A, 0x42, 0xD4, 0x7A, 0x03,  //  ...B.z.
                /* 1B80 */  0x61, 0x7A, 0x1E, 0x85, 0x1A, 0x0A, 0x01, 0xA1,  // az......
                /* 1B88 */  0xCA, 0xD5, 0x9D, 0x63, 0x58, 0x0E, 0x10, 0x9A,  // ...cX...
                /* 1B90 */  0x0B, 0x44, 0x60, 0x56, 0xE1, 0x0E, 0x88, 0xA9,  // .D`V....
                /* 1B98 */  0x02, 0x11, 0x90, 0x13, 0x00, 0xD1, 0x54, 0x20,  // ......T 
                /* 1BA0 */  0x34, 0x25, 0x18, 0xD5, 0x25, 0x0F, 0x88, 0x25,  // 4%..%..%
                /* 1BA8 */  0x00, 0xA1, 0xA9, 0x40, 0x68, 0x4A, 0x10, 0x01,  // ...@hJ..
                /* 1BB0 */  0x5A, 0x95, 0x3D, 0x20, 0xA6, 0x14, 0x84, 0x2A,  // Z.= ...*
                /* 1BB8 */  0x07, 0xA1, 0xE9, 0x40, 0xA8, 0x6C, 0x7D, 0x87,  // ...@.l}.
                /* 1BC0 */  0x05, 0x0A, 0x22, 0x20, 0x47, 0x07, 0xA1, 0xC2,  // .." G...
                /* 1BC8 */  0xFD, 0x81, 0x30, 0xBD, 0x2F, 0x0D, 0x01, 0x3A,  // ..0./..:
                /* 1BD0 */  0x1D, 0x88, 0x80, 0x9C, 0x18, 0x84, 0x2A, 0xF8,  // ......*.
                /* 1BD8 */  0x64, 0x04, 0x21, 0x62, 0x41, 0xA8, 0x82, 0x4F,  // d.!bA..O
                /* 1BE0 */  0x46, 0x50, 0xA2, 0xE5, 0x65, 0x27, 0x20, 0xEB,  // FP..e' .
                /* 1BE8 */  0x03, 0xA1, 0x7A, 0x41, 0x04, 0xE6, 0x6C, 0x40,  // ..zA..l@
                /* 1BF0 */  0x34, 0x2F, 0x08, 0xCD, 0x0F, 0x46, 0xB5, 0x1A,  // 4/...F..
                /* 1BF8 */  0x05, 0x62, 0xFA, 0x41, 0x68, 0x1E, 0x10, 0x81,  // .b.Ah...
                /* 1C00 */  0x59, 0xC1, 0xF3, 0xE3, 0x80, 0x19, 0x08, 0x55,  // Y......U
                /* 1C08 */  0x09, 0x22, 0x30, 0xE7, 0x02, 0xA2, 0x59, 0x41,  // ."0...YA
                /* 1C10 */  0x68, 0x76, 0x10, 0xFD, 0xFF, 0xC1, 0xAC, 0xFD,  // hv......
                /* 1C18 */  0x1F, 0xA2, 0x01, 0x10, 0x10, 0x9A, 0x0F, 0x44,  // .......D
                /* 1C20 */  0x87, 0x01, 0xF2, 0x2C, 0x13, 0x90, 0x35, 0x82,  // ...,..5.
                /* 1C28 */  0x50, 0xCD, 0x20, 0x3A, 0x1E, 0x10, 0x20, 0x9A,  // P. :.. .
                /* 1C30 */  0x1F, 0x84, 0xEA, 0xF9, 0x9B, 0x04, 0x23, 0x19,  // ......#.
                /* 1C38 */  0x40, 0x04, 0x64, 0x2D, 0x4F, 0xD0, 0x40, 0x44,  // @.d-O.@D
                /* 1C40 */  0x3F, 0x88, 0x80, 0x9C, 0x09, 0x84, 0x66, 0x04,  // ?.....f.
                /* 1C48 */  0xA3, 0x6A, 0xDF, 0x3A, 0x3A, 0x0E, 0x10, 0x10,  // .j.::...
                /* 1C50 */  0x9A, 0x08, 0x44, 0xC3, 0x23, 0xEF, 0x9E, 0xC3,  // ..D.#...
                /* 1C58 */  0x63, 0x20, 0x54, 0x25, 0x88, 0xC0, 0xAC, 0xF1,  // c T%....
                /* 1C60 */  0xE9, 0x22, 0x10, 0x27, 0x04, 0xA1, 0xEA, 0xED,  // .".'....
                /* 1C68 */  0x1E, 0x18, 0xA8, 0xDE, 0x41, 0x50, 0xC1, 0x83,  // ....AP..
                /* 1C70 */  0xA0, 0x20, 0x34, 0x11, 0x88, 0x0E, 0x19, 0xE4,  // . 4.....
                /* 1C78 */  0x7D, 0x26, 0x20, 0xEB, 0x02, 0xA1, 0x3A, 0x41,  // }& ...:A
                /* 1C80 */  0x34, 0x64, 0x02, 0x44, 0xB3, 0x82, 0xD0, 0xEC,  // 4d.D....
                /* 1C88 */  0x60, 0x34, 0xFB, 0x37, 0x49, 0xC3, 0x20, 0xDF,  // `4.7I. .
                /* 1C90 */  0x2B, 0x1D, 0x18, 0xC8, 0x23, 0x2E, 0x08, 0x51,  // +...#..Q
                /* 1C98 */  0xF4, 0x31, 0x12, 0x88, 0x73, 0xBF, 0x81, 0x34,  // .1..s..4
                /* 1CA0 */  0x50, 0xF2, 0x98, 0x09, 0x42, 0xB4, 0x81, 0x08,  // P...B...
                /* 1CA8 */  0xCC, 0x39, 0x80, 0x68, 0x36, 0x10, 0x9A, 0x15,  // .9.h6...
                /* 1CB0 */  0x8C, 0x66, 0x55, 0x7D, 0xC4, 0xA0, 0x3F, 0x9B,  // .fU}..?.
                /* 1CB8 */  0x43, 0x63, 0xCF, 0x2B, 0x81, 0x58, 0xC9, 0xCB,  // Cc.+.X..
                /* 1CC0 */  0xE6, 0xD1, 0x82, 0xFD, 0x6C, 0x05, 0x42, 0x8C,  // ....l.B.
                /* 1CC8 */  0x03, 0xD3, 0xEF, 0x8D, 0x8E, 0x01, 0x04, 0x84,  // ........
                /* 1CD0 */  0xEA, 0xF9, 0x5D, 0xE9, 0x08, 0x40, 0x40, 0x74,  // ..]..@@t
                /* 1CD8 */  0x04, 0x20, 0x20, 0x34, 0x23, 0x08, 0xCD, 0x0E,  // .  4#...
                /* 1CE0 */  0x42, 0x75, 0xBD, 0xD7, 0x04, 0x6A, 0x6D, 0xDE,  // Bu...jm.
                /* 1CE8 */  0x41, 0x58, 0x32, 0x10, 0xAA, 0x5A, 0x3C, 0x08,  // AX2..Z<.
                /* 1CF0 */  0x53, 0xFC, 0x60, 0xD3, 0x30, 0x89, 0xFA, 0x43,  // S.`.0..C
                /* 1CF8 */  0x00, 0x7D, 0x9E, 0x09, 0xDC, 0xBA, 0x41, 0xF4,  // .}....A.
                /* 1D00 */  0xFF, 0x3F, 0x80, 0x10, 0x10, 0x0D, 0x94, 0x00,  // .?......
                /* 1D08 */  0x51, 0x2D, 0x5F, 0x3A, 0x0D, 0x94, 0x80, 0x08,  // Q-_:....
                /* 1D10 */  0xCC, 0x99, 0x80, 0x68, 0x4E, 0x10, 0x9A, 0x1B,  // ...hN...
                /* 1D18 */  0x84, 0xAA, 0xD0, 0x3F, 0x10, 0x0A, 0x22, 0x20,  // ...?.." 
                /* 1D20 */  0xA7, 0x00, 0xA1, 0xA9, 0xC0, 0xA8, 0x0E, 0xFF,  // ........
                /* 1D28 */  0x43, 0xA0, 0x20, 0x54, 0x2B, 0x88, 0x8E, 0x17,  // C. T+...
                /* 1D30 */  0x24, 0x01, 0x08, 0x4B, 0x0A, 0x42, 0x53, 0x34,  // $..K.BS4
                /* 1D38 */  0x38, 0x9A, 0xD0, 0x08, 0x80, 0xB4, 0x02, 0x08,  // 8.......
                /* 1D40 */  0xD3, 0x1B, 0x02, 0x84, 0xA5, 0x05, 0xA1, 0x49,  // .......I
                /* 1D48 */  0x4A, 0x00, 0xD3, 0x14, 0x20, 0x2C, 0x31, 0x88,  // J... ,1.
                /* 1D50 */  0x86, 0x44, 0x5A, 0x1C, 0x1F, 0x28, 0x88, 0xC0,  // .DZ..(..
                /* 1D58 */  0x2C, 0x36, 0xC7, 0x91, 0x84, 0x82, 0xD0, 0x30,  // ,6.....0
                /* 1D60 */  0x20, 0x3A, 0xC6, 0x38, 0x19, 0x88, 0x8E, 0x0D,  //  :.8....
                /* 1D68 */  0xA4, 0xC7, 0x41, 0x80, 0x82, 0x50, 0x8D, 0x20,  // ..A..P. 
                /* 1D70 */  0x02, 0xB4, 0x60, 0x10, 0x1D, 0x4E, 0x08, 0x18,  // ..`..N..
                /* 1D78 */  0x4D, 0x0A, 0x42, 0xD3, 0x03, 0x52, 0x29, 0x41,  // M.B..R)A
                /* 1D80 */  0x8E, 0x44, 0x14, 0x44, 0x60, 0x8E, 0x02, 0x42,  // .D.D`..B
                /* 1D88 */  0xE3, 0x81, 0x08, 0xD0, 0x59, 0x01, 0xA9, 0xC0,  // ....Y...
                /* 1D90 */  0x22, 0x07, 0x15, 0x0A, 0x42, 0x03, 0x80, 0x08,  // "...B...
                /* 1D98 */  0xD0, 0x69, 0x40, 0x74, 0x24, 0x22, 0x60, 0x54,  // .i@t$"`T
                /* 1DA0 */  0x4A, 0x12, 0x10, 0x26, 0x0F, 0x44, 0x80, 0xD6,  // J..&.D..
                /* 1DA8 */  0x0A, 0xA2, 0x83, 0x03, 0x69, 0x72, 0x4C, 0xA0,  // ....irL.
                /* 1DB0 */  0x20, 0x34, 0x0F, 0x08, 0x95, 0x5E, 0x05, 0x94,  //  4...^..
                /* 1DB8 */  0x05, 0x01, 0xD1, 0xF1, 0x89, 0x64, 0x19, 0x00,  // .....d..
                /* 1DC0 */  0x05, 0xA1, 0xA2, 0x41, 0x68, 0x08, 0x10, 0x2A,  // ...Ah..*
                /* 1DC8 */  0x30, 0x0C, 0x28, 0x8B, 0x07, 0x42, 0x75, 0x3C,  // 0.(..Bu<
                /* 1DD0 */  0xF8, 0x04, 0x66, 0x4D, 0x20, 0x54, 0x27, 0x88,  // ..fM T'.
                /* 1DD8 */  0xFE, 0xFF, 0x83, 0xB0, 0x68, 0x10, 0x01, 0x3A,  // ....h..:
                /* 1DE0 */  0x1F, 0x18, 0xCD, 0x0A, 0x42, 0xF3, 0x03, 0x52,  // ....B..R
                /* 1DE8 */  0x31, 0x75, 0x8E, 0x58, 0x14, 0x44, 0x60, 0x8E,  // 1u.X.D`.
                /* 1DF0 */  0x01, 0x42, 0xA3, 0x81, 0x08, 0xD0, 0x39, 0x01,  // .B....9.
                /* 1DF8 */  0x69, 0x8A, 0x3C, 0x47, 0x0B, 0x0A, 0x42, 0xB3,  // i.<G..B.
                /* 1E00 */  0x83, 0xD0, 0xA8, 0x7D, 0x8E, 0x4A, 0x14, 0x44,  // ...}.J.D
                /* 1E08 */  0xA0, 0x16, 0x1E, 0x08, 0x8C, 0xC5, 0x01, 0xA1,  // ........
                /* 1E10 */  0x21, 0x41, 0x68, 0x68, 0x10, 0x9A, 0xA6, 0x10,  // !Ahh....
                /* 1E18 */  0x08, 0x4B, 0x06, 0x42, 0xD3, 0x82, 0x68, 0x00,  // .K.B..h.
                /* 1E20 */  0x8E, 0x0E, 0xA2, 0xC3, 0x04, 0x49, 0x04, 0xC6,  // .....I..
                /* 1E28 */  0xD4, 0x83, 0xD0, 0x44, 0x20, 0x02, 0x74, 0x3C,  // ...D .t<
                /* 1E30 */  0x10, 0x1D, 0xB4, 0x48, 0xA3, 0x83, 0x01, 0x05,  // ...H....
                /* 1E38 */  0xA1, 0x91, 0x41, 0x68, 0xC2, 0x57, 0xA8, 0x40,  // ..Ah.W.@
                /* 1E40 */  0x9D, 0x17, 0x44, 0x07, 0x09, 0x52, 0xE9, 0x78,  // ..D..R.x
                /* 1E48 */  0x41, 0x41, 0x68, 0x36, 0x10, 0x9A, 0x15, 0x84,  // AAh6....
                /* 1E50 */  0xE6, 0xE8, 0x74, 0x30, 0xA1, 0xA1, 0x0E, 0x00,  // ..t0....
                /* 1E58 */  0x34, 0xD5, 0x21, 0x83, 0x82, 0x50, 0xAD, 0x20,  // 4.!..P. 
                /* 1E60 */  0x3A, 0x3C, 0x10, 0x20, 0x9A, 0x18, 0x84, 0x2A,  // :<. ...*
                /* 1E68 */  0x68, 0x05, 0x48, 0x41, 0x04, 0x48, 0x80, 0x68,  // h.HA.H.h
                /* 1E70 */  0x62, 0x10, 0xAA, 0x20, 0x16, 0x08, 0x93, 0x0A,  // b.. ....
                /* 1E78 */  0x42, 0xA3, 0x83, 0x08, 0xD4, 0x82, 0x6B, 0x1D,  // B.....k.
                /* 1E80 */  0x10, 0x28, 0x08, 0x0D, 0x05, 0xA2, 0xA3, 0x1C,  // .(......
                /* 1E88 */  0xC9, 0x75, 0x48, 0xA0, 0x20, 0x54, 0x30, 0x08,  // .uH. T0.
                /* 1E90 */  0x4D, 0x07, 0x42, 0xC5, 0xF7, 0x3A, 0x88, 0x51,  // M.B..:.Q
                /* 1E98 */  0x10, 0x01, 0x59, 0xC4, 0x23, 0x5E, 0x20, 0x16,  // ..Y.#^ .
                /* 1EA0 */  0x05, 0x22, 0x30, 0x47, 0x01, 0xA2, 0xF1, 0x40,  // ."0G...@
                /* 1EA8 */  0x68, 0x78, 0x30, 0x2A, 0xB4, 0x1A, 0xC4, 0xFF,  // hx0*....
                /* 1EB0 */  0xFF, 0x01, 0x8B, 0x80, 0xD0, 0x38, 0xD9, 0x0E,  // .....8..
                /* 1EB8 */  0x06, 0x34, 0xDC, 0xF1, 0x83, 0x82, 0xD0, 0x70,  // .4.....p
                /* 1EC0 */  0x20, 0x34, 0x3E, 0x08, 0x95, 0x5A, 0xEE, 0x18,  //  4>..Z..
                /* 1EC8 */  0x41, 0x41, 0x74, 0x10, 0x20, 0x20, 0x54, 0x42,  // AAt.  TB
                /* 1ED0 */  0xBA, 0x01, 0x50, 0x10, 0x0D, 0x80, 0x80, 0xD0,  // ..P.....
                /* 1ED8 */  0x70, 0x60, 0x54, 0x46, 0x3E, 0x10, 0x16, 0x02,  // p`TF>...
                /* 1EE0 */  0x84, 0x8A, 0xED, 0x07, 0xC2, 0xFE, 0xFF         // .......
            })
        }

        Method (UPWS, 0, NotSerialized)
        {
            If (W8OS ()){}
            ElseIf (BNLS)
            {
                If (WLDS)
                {
                    If (((^WMID.WMIF != Zero) && !WWLS)){}
                    Else
                    {
                    }
                }

                If (BTDS)
                {
                    If (((^WMID.WMIF != Zero) && !WBTS)){}
                    Else
                    {
                    }
                }
            }
            Else
            {
                If (WLDS){}
                If (BTDS){}
            }
        }

        Method (CBCD, 0, NotSerialized)
        {
            If (^PCI0.SBRG.EC0.ECON)
            {
                Local0 = ^PCI0.SBRG.EC0.RA60 /* \_SB_.PCI0.SBRG.EC0_.RA60 */
                Local0 &= 0xE4
                ^PCI0.SBRG.EC0.MBDC = Local0
            }
        }

        Method (CPUS, 1, NotSerialized)
        {
            Local0 = Arg0
            If (CondRefOf (\_SB.PLTF.C000.PPCV))
            {
                ^PLTF.C000.PPCV = Local0
                Notify (^PLTF.C000, 0x80) // Status Change
                If ((NUCO > One))
                {
                    ^PLTF.C001.PPCV = Local0
                    Notify (^PLTF.C001, 0x80) // Status Change
                }

                If ((NUCO > 0x02))
                {
                    ^PLTF.C002.PPCV = Local0
                    Notify (^PLTF.C002, 0x80) // Status Change
                }

                If ((NUCO > 0x03))
                {
                    ^PLTF.C003.PPCV = Local0
                    Notify (^PLTF.C003, 0x80) // Status Change
                }
            }
        }
    }

    Scope (_SB)
    {
        Name (FLAG, 0x05)
        Name (N000, Zero)
        Name (N017, Zero)
        Name (N001, Buffer (0x80){})
        Name (N002, Buffer (0x0400){})
        Name (N003, Buffer (0x04){})
        Name (N004, Buffer (0x64)
        {
            /* 0000 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0008 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0010 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0018 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0020 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0028 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0030 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0038 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0040 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0048 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0050 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0058 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
            /* 0060 */  0xFF, 0xFF, 0xFF, 0xFF                           // ....
        })
        Name (TEMP, Buffer (0x32){})
        Name (ST01, Buffer (0x64){})
        Name (ST02, Buffer (0x0200){})
        Name (ST14, Buffer (0x32){})
        Name (BF01, Buffer (0x32){})
        Name (N005, Buffer (0x0190){})
        Name (N006, "Information Not Available")
        Name (YESY, "Yes")
        Name (NONO, "No")
        Name (N007, "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ")
        Name (N008, "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ")
        Name (N009, Buffer (0x1000){})
        Name (N00A, Package (0x5D)
        {
            Package (0x1C)
            {
                "Language", 
                " *English, Francais, Espanol, Traditional Chinese, Simplified Chinese", 
                "\\System Configuration", 
                Zero, 
                One, 
                Zero, 
                0x78, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "English", 
                0x05, 
                "English", 
                "Francais", 
                "Espanol", 
                "Traditional Chinese", 
                "Simplified Chinese"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Fan Always On", 
                "", 
                "\\System Configuration", 
                Zero, 
                One, 
                Zero, 
                0x8C, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Enable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                "Action Keys Mode", 
                "", 
                "\\System Configuration", 
                Zero, 
                One, 
                Zero, 
                0x96, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Enable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "POST Hotkey Delay (sec)", 
                "", 
                "\\System Configuration\\Boot Options", 
                Zero, 
                One, 
                Zero, 
                0xC8, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "0", 
                0x05, 
                "0", 
                "5", 
                "10", 
                "15", 
                "20"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Network Boot", 
                "", 
                "\\System Configuration\\Boot Options", 
                Zero, 
                One, 
                Zero, 
                0xF0, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Disable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                "Network Boot Protocol", 
                "", 
                "\\System Configuration\\Boot Options", 
                Zero, 
                One, 
                Zero, 
                0xF5, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "IPv4+IPv6 (UEFI)", 
                0x03, 
                "IPv4 (UEFI)", 
                "IPv6 (UEFI)", 
                "IPv4+IPv6 (UEFI)"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Secure Boot", 
                "", 
                "\\System Configuration\\Boot Options", 
                Zero, 
                One, 
                Zero, 
                0x0104, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Disable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                "Clear All Secure Boot Keys", 
                "", 
                "\\System Configuration\\Boot Options", 
                One, 
                Zero, 
                One, 
                0x010A, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "No", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                "Load HP Factory Default Keys", 
                "", 
                "\\System Configuration\\Boot Options", 
                One, 
                Zero, 
                One, 
                0x010C, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "No", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Manufacturing Programming Mode", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x0377, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Unlock", 
                0x02, 
                "Lock", 
                "Unlock"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "TPM Device", 
                "", 
                "\\Security", 
                Zero, 
                One, 
                Zero, 
                0x0258, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Hidden", 
                0x02, 
                "Hidden", 
                "Available"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "TPM Reset to Factory Defaults", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x0384, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "No", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                "TPM State", 
                "", 
                "\\Security", 
                Zero, 
                One, 
                Zero, 
                0x025D, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Disable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                "Clear TPM", 
                "", 
                "\\Security", 
                Zero, 
                One, 
                Zero, 
                0x0262, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "No", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Load MSFT Debug Policy Keys", 
                "", 
                "\\System Configuration\\Boot Options", 
                One, 
                Zero, 
                One, 
                0x010E, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "No", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Keyboard Type", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x16, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Non-Japanese Keyboard (Default US)", 
                0x09, 
                "Non-Japanese Keyboard (Default US)", 
                "Japanese Keyboard", 
                "New EMEA UK KB (US2)", 
                "New BRZL KB (UK2)", 
                "New BRZL KB (US3)", 
                "US4 (LA KB)", 
                "US5 (Europe KB)", 
                "US6 (Korea KB)", 
                "US7 (Brazil KB)"
            }, 

            Package (0x1C)
            {
                "Restore Security Defaults", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x0398, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "No", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Secure Boot Keys", 
                "", 
                "\\System Configuration\\Boot Options", 
                Zero, 
                One, 
                Zero, 
                0x039D, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Clear", 
                0x04, 
                "Clear", 
                "HP", 
                "MSFT", 
                "Custom"
            }, 

            Package (0x1C)
            {
                "PIN Load Defaults", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03A2, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "No", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                "OOBE", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                Zero, 
                Zero, 
                0x03A4, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "No", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                "Clear Event Log", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                Zero, 
                Zero, 
                0x03A6, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "No", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Enable MS UEFI CA key", 
                "", 
                "\\System Configuration", 
                Zero, 
                One, 
                Zero, 
                0x03AC, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Yes", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                "Clear BOD", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03AE, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "No", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                "Reflow Process", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03B0, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "No", 
                0x02, 
                "No", 
                "Yes"
            }, 

            Package (0x1C)
            {
                "USB Boot", 
                "", 
                "\\System Configuration\\Boot Options", 
                Zero, 
                One, 
                Zero, 
                0xEB, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Disable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Adaptive Battery Extender", 
                "", 
                "\\System Configuration", 
                Zero, 
                One, 
                Zero, 
                0xC5, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Disable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                "Adaptive Battery Extender Status", 
                "", 
                "\\dir Place holder for Path", 
                One, 
                One, 
                Zero, 
                0xC6, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Not Activated", 
                0x02, 
                "Not Activated", 
                "Activated"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "AOS Deployment AddOn", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03B3, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Disable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Power on when Lid is opened", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03B6, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Enable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Battery Remaining Time", 
                "", 
                "\\dir Place holder for Path", 
                One, 
                One, 
                Zero, 
                0x03B8, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Enable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                "Connected System Recovery", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03B8, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Enable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Battery Health Manager", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03BD, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Maximize my battery health Off", 
                0x02, 
                "Maximize my battery health On", 
                "Maximize my battery health Off"
            }, 

            Package (0x1C)
            {
                "Pluton Device", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03BE, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Enable", 
                0x02, 
                "Disable", 
                "Enable"
            }, 

            Package (0x1C)
            {
                "TPM Solution", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03BF, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "Pluton", 
                0x02, 
                "Pluton", 
                "SoC"
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                " ", 
                Zero
            }, 

            Package (0x1C)
            {
                "Keyboard Backlight Timeout", 
                "", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03C2, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                "30 sec", 
                0x03, 
                "Never", 
                "30 sec", 
                "3 min"
            }
        })
        Name (N00B, Package (0x01)
        {
            Package (0x10)
            {
                "Setup Password", 
                " ", 
                "\\Security", 
                Zero, 
                One, 
                Zero, 
                Zero, 
                One, 
                " ", 
                Zero, 
                One, 
                0x20, 
                "utf-16", 
                "", 
                Zero, 
                One
            }
        })
        Name (N00C, Package (0x01)
        {
            Package (0x0F)
            {
                "Manufacturing Programming Mode Counter", 
                "Place holder ", 
                "\\Place holder for Path", 
                One, 
                Zero, 
                One, 
                0x0376, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0A, 
                Zero
            }
        })
        Name (N00D, Package (0x1E)
        {
            Package (0x0E)
            {
                "Feature Byte", 
                " ", 
                "\\Main", 
                Zero, 
                One, 
                Zero, 
                0x02, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "Build ID", 
                " ", 
                "\\Main", 
                Zero, 
                One, 
                Zero, 
                0x04, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "Serial Number", 
                " ", 
                "\\Main", 
                Zero, 
                One, 
                Zero, 
                0x08, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "Product Name", 
                " ", 
                "\\Main", 
                Zero, 
                One, 
                Zero, 
                0x0A, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "UUID", 
                " ", 
                "\\Main", 
                Zero, 
                One, 
                Zero, 
                0x0E, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "Product Number", 
                " ", 
                "\\Main", 
                Zero, 
                One, 
                Zero, 
                0x10, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "MAC Address", 
                " ", 
                "\\Main", 
                Zero, 
                Zero, 
                Zero, 
                0x12, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "System Board CT Number", 
                " ", 
                "\\Main", 
                Zero, 
                One, 
                Zero, 
                0x14, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "MS Digital Marker", 
                " ", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x16, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "SmartAMP R0", 
                " ", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x18, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x01F4
            }, 

            Package (0x0E)
            {
                "System Board ID", 
                " ", 
                "\\dir Place holder for Path", 
                One, 
                One, 
                Zero, 
                0x1A, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "System Family", 
                " ", 
                "\\Main", 
                Zero, 
                One, 
                Zero, 
                0x1C, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "Preinstall OS Version", 
                " ", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x1E, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "Speaker ID", 
                " ", 
                "\\dir Place holder for Path", 
                One, 
                One, 
                Zero, 
                0x22, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "PIN Process Cycle", 
                " ", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x24, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                " ", 
                " ", 
                " ", 
                One, 
                Zero, 
                One, 
                Zero, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "BIOS Revision", 
                " ", 
                "\\dir Place holder for Path", 
                One, 
                One, 
                Zero, 
                0x03BE, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "Batt_LTemp", 
                " ", 
                "\\dir Place holder for Path", 
                One, 
                One, 
                Zero, 
                0x03BF, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "Keyboard Layout", 
                " ", 
                "\\dir Place holder for Path", 
                One, 
                One, 
                Zero, 
                0x03C0, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "HW Platform Cycle", 
                " ", 
                "\\dir Place holder for Path", 
                One, 
                One, 
                Zero, 
                0x03C1, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "DRR", 
                " ", 
                "\\dir Place holder for Path", 
                One, 
                One, 
                Zero, 
                0x03C2, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "Network Boot TFTP Window Size", 
                " ", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03C3, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "SCPC capable", 
                " ", 
                "\\dir Place holder for Path", 
                Zero, 
                One, 
                Zero, 
                0x03C4, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }, 

            Package (0x0E)
            {
                "MSFT Copilot Key", 
                "", 
                "\\dir Place holder for Path", 
                One, 
                One, 
                Zero, 
                0x03C5, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                Zero, 
                0x0100
            }
        })
    }

    Scope (_SB)
    {
        Name (N010, Buffer (0x04)
        {
             0xFF, 0xFF, 0xFF, 0xFF                           // ....
        })
        Name (N011, Buffer (0x04)
        {
             0xFF, 0xFF, 0xFF, 0xFF                           // ....
        })
        Name (N012, Package (0x02)
        {
            Package (0x12)
            {
                "Legacy Boot Order", 
                " Internal Hard Drive, USB Flash Drive/USB Hard Disk, USB CD/DVD ROM Drive, Network Adapter,", 
                "\\System Configuration\\Boot Options", 
                One, 
                Zero, 
                One, 
                0x0122, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                0x04, 
                " Internal Hard Drive", 
                " USB Flash Drive/USB Hard Disk", 
                " USB CD/DVD ROM Drive", 
                " Network Adapter", 
                " "
            }, 

            Package (0x12)
            {
                "UEFI Boot Order", 
                " OS Boot Manager, USB Flash Drive/USB Hard Disk, USB CD/DVD ROM Drive, Network Adapter,", 
                "\\System Configuration\\Boot Options", 
                Zero, 
                One, 
                Zero, 
                0x0118, 
                0x03, 
                " ", 
                " ", 
                " ", 
                Zero, 
                0x04, 
                " OS Boot Manager", 
                " USB Flash Drive/USB Hard Disk", 
                " USB CD/DVD ROM Drive", 
                " Network Adapter", 
                " "
            }
        })
        Name (N013, Package (0x04)
        {
            Package (0x02)
            {
                One, 
                " Internal Hard Drive"
            }, 

            Package (0x02)
            {
                0x02, 
                " USB Flash Drive/USB Hard Disk"
            }, 

            Package (0x02)
            {
                0x03, 
                " USB CD/DVD ROM Drive"
            }, 

            Package (0x02)
            {
                0x04, 
                " Network Adapter"
            }
        })
        Name (N014, Package (0x04)
        {
            Package (0x02)
            {
                One, 
                " OS Boot Manager"
            }, 

            Package (0x02)
            {
                0x02, 
                " USB Flash Drive/USB Hard Disk"
            }, 

            Package (0x02)
            {
                0x03, 
                " USB CD/DVD ROM Drive"
            }, 

            Package (0x02)
            {
                0x04, 
                " Network Adapter"
            }
        })
        Name (N015, Package (0x04)
        {
            " Boot Device 1", 
            " Boot Device 2", 
            " Boot Device 3", 
            " Boot Device 4"
        })
        Name (N016, Package (0x04)
        {
            " UEFI Boot Device 1", 
            " UEFI Boot Device 2", 
            " UEFI Boot Device 3", 
            " UEFI Boot Device 4"
        })
        Name (N023, Package (0x15)
        {
            "HBMA Priority List", 
            " USB NIC Dongle:HP External Adapter :0BDA_8153, Embedded NIC:Intel I219-LM :8086_15E3 (disabled), Thunderbolt Dock:HP Elite Dock :14E4_1682:14E4_1682, USB NIC Dongle:HP USB-C Travel Dock :17E9_4352, USB NIC Dongle:HP USB Travel Dock :17E9_4351, USB NIC Dongle:HP 3005pr :17E9_430A, USB NIC Dongle:HP Universal pr :17E9_4327", 
            "\\System Configuration\\Boot Options", 
            One, 
            One, 
            Zero, 
            0x03C6, 
            0x03, 
            " ", 
            " ", 
            " ", 
            Zero, 
            0x07, 
            " USB NIC Dongle:HP External Adapter :0BDA_8153", 
            " Embedded NIC:Intel I219-LM :8086_15E3 (disabled)", 
            " Thunderbolt Dock:HP Elite Dock :14E4_1682:14E4_1682", 
            " USB NIC Dongle:HP USB-C Travel Dock :17E9_4352", 
            " USB NIC Dongle:HP USB Travel Dock :17E9_4351", 
            " USB NIC Dongle:HP 3005pr :17E9_430A", 
            " USB NIC Dongle:HP Universal pr :17E9_4327", 
            " "
        })
    }

    Scope (_SB.WMID)
    {
        OperationRegion (MPBS, SystemMemory, 0xFF8FF000, 0x08)
        Field (MPBS, ByteAcc, NoLock, Preserve)
        {
            MFLG,   64
        }

        Name (NULL, "                                      ")
        Name (N018, 0x04)
        Name (N019, 0x04)
        Method (WQBC, 1, NotSerialized)
        {
            Acquire (MUTZ, 0xFFFF)
            Local0 = WQBX (Arg0)
            Release (MUTZ)
            Return (Local0)
        }

        Method (WQBX, 1, NotSerialized)
        {
            M000 ()
            WSMI (0xEA7B, Zero, One, Arg0, Zero)
            If ((AEBX == 0x80))
            {
                DerefOf (N00A [Arg0]) [Zero] = " "
                DerefOf (N00A [Arg0]) [0x04] = Zero
                DerefOf (N00A [Arg0]) [0x03] = One
                DerefOf (N00A [Arg0]) [0x05] = One
            }

            If ((AEBX == 0x81))
            {
                DerefOf (N00A [Arg0]) [0x03] = One
            }

            Local5 = DerefOf (N00A [Arg0])
            Local0 = DerefOf (Local5 [Zero])
            If ((NOFN == One))
            {
                If (SCMP (Local0, "Fan Always On"))
                {
                    DerefOf (N00A [Arg0]) [0x04] = Zero
                    DerefOf (N00A [Arg0]) [0x03] = One
                }
            }

            If ((HIPD == One))
            {
                If (SCMP (Local0, "Pluton Device"))
                {
                    DerefOf (N00A [Arg0]) [0x04] = Zero
                    DerefOf (N00A [Arg0]) [0x03] = One
                }
            }
            ElseIf (SCMP (Local0, "TPM Solution"))
            {
                DerefOf (N00A [Arg0]) [0x04] = Zero
                DerefOf (N00A [Arg0]) [0x03] = One
            }

            If ((HIKL == One))
            {
                If (SCMP (Local0, "Keyboard Backlight Timeout"))
                {
                    DerefOf (N00A [Arg0]) [0x04] = Zero
                    DerefOf (N00A [Arg0]) [0x03] = One
                }
            }

            If (SRCM (MFLG, "MPMLock", 0x07))
            {
                If (SCMP (Local0, "Manufacturing Programming Mode"))
                {
                    DerefOf (N00A [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "Legacy Support"))
                {
                    DerefOf (N00A [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "Secure Boot"))
                {
                    DerefOf (N00A [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "Secure Boot Keys"))
                {
                    DerefOf (N00A [Arg0]) [0x03] = One
                    DerefOf (N00A [Arg0]) [0x04] = Zero
                    DerefOf (N00A [Arg0]) [0x05] = One
                }

                If (SCMP (Local0, "Keyboard Type"))
                {
                    DerefOf (N00A [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "Clear BOD"))
                {
                    DerefOf (N00A [Arg0]) [0x03] = One
                    DerefOf (N00A [Arg0]) [0x04] = Zero
                    DerefOf (N00A [Arg0]) [0x05] = One
                }

                If (SCMP (Local0, "Reflow Process"))
                {
                    DerefOf (N00A [Arg0]) [0x03] = One
                    DerefOf (N00A [Arg0]) [0x04] = Zero
                    DerefOf (N00A [Arg0]) [0x05] = One
                }

                If (SCMP (Local0, "TPM Reset to Factory Defaults"))
                {
                    DerefOf (N00A [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "Restore Security Defaults"))
                {
                    DerefOf (N00A [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "Clear TPM"))
                {
                    DerefOf (N00A [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "AOS Deployment AddOn"))
                {
                    DerefOf (N00A [Arg0]) [0x03] = One
                }
            }

            If (SCMP (Local0, "Adaptive Battery Extender Status"))
            {
                AEDX = ABES ()
            }

            Local6 = AEDX /* \AEDX */
            Local4 = SizeOf (Local5)
            Local2 = DerefOf (Local5 [0x0D])
            Local2 += 0x0E
            If ((Local2 < Local4))
            {
                Local4 = Local2
            }

            Local6 += 0x0E
            If ((Local2 < Local6))
            {
                Local6 = Local2
            }

            Local7 = DerefOf (DerefOf (N00A [Arg0]) [Local6])
            DerefOf (N00A [Arg0]) [0x0C] = Local7
            Local1 = " "
            Local2 = 0x0E
            While ((Local2 < Local6))
            {
                Local3 = DerefOf (Local5 [Local2])
                Concatenate (Local1, Local3, Local7)
                Concatenate (Local7, ", ", Local1)
                Local2++
            }

            Concatenate (Local1, "*", Local7)
            While ((Local2 < Local4))
            {
                Local3 = DerefOf (Local5 [Local2])
                If (SCMP (Local3, " "))
                {
                    Break
                }
                Else
                {
                    If ((Local2 != Local6))
                    {
                        Concatenate (Local7, ", ", Local1)
                    }
                    Else
                    {
                        Local1 = Local7
                    }

                    Concatenate (Local1, Local3, Local7)
                }

                Local2++
            }

            DerefOf (N00A [Arg0]) [One] = Local7
            Return (DerefOf (N00A [Arg0]))
        }

        Method (WQBD, 1, NotSerialized)
        {
            Acquire (MUTZ, 0xFFFF)
            Local0 = WQBY (Arg0)
            Release (MUTZ)
            Return (Local0)
        }

        Method (WQBY, 1, NotSerialized)
        {
            Local0 = Zero
            Local1 = Zero
            Local2 = Zero
            Local4 = Zero
            Local5 = Zero
            Local6 = Zero
            Local7 = Zero
            WSMI (0xEA7B, Zero, 0x02, Arg0, Zero)
            If ((AEBX == 0x80))
            {
                DerefOf (N00D [Arg0]) [Zero] = " "
                DerefOf (N00D [Arg0]) [0x04] = Zero
                DerefOf (N00D [Arg0]) [0x03] = One
                DerefOf (N00D [Arg0]) [0x05] = One
                N007 = N006 /* \_SB_.N006 */
            }
            ElseIf ((AECX != Zero))
            {
                N002 = SBUF /* \SBUF */
                CreateField (N002, Zero, (AECX * 0x08), WSTR)
                N007 = WSTR /* \_SB_.WMID.WQBY.WSTR */
            }
            Else
            {
                DerefOf (N00D [Arg0]) [0x04] = Zero
                N007 = N006 /* \_SB_.N006 */
            }

            DerefOf (N00D [Arg0]) [One] = N007 /* \_SB_.N007 */
            Local5 = DerefOf (N00D [Arg0])
            Local0 = DerefOf (Local5 [Zero])
            If (SRCM (MFLG, "MPMLock", 0x07))
            {
                If (SCMP (Local0, "Serial Number"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "Product Name"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "UUID"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "Product Number"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "MAC Address"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "System Board CT Number"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "SmartAMP R0"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "System Family"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "Preinstall OS Version"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "Feature Byte"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "Build ID"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }

                If (SCMP (Local0, "PIN Process Cycle"))
                {
                    DerefOf (N00D [Arg0]) [0x03] = One
                }
            }

            If ((HIWS == One))
            {
                If (SCMP (Local0, "Network Boot TFTP Window Size"))
                {
                    DerefOf (N00D [Arg0]) [0x04] = Zero
                    DerefOf (N00D [Arg0]) [0x03] = One
                }
            }

            Return (DerefOf (N00D [Arg0]))
        }

        Method (WQBE, 1, NotSerialized)
        {
            Acquire (MUTZ, 0xFFFF)
            Local0 = WQBZ (Arg0)
            Release (MUTZ)
            Return (Local0)
        }

        Method (WQBZ, 1, NotSerialized)
        {
            Local1 = Zero
            Local2 = Zero
            Local4 = Zero
            Local5 = Zero
            Local6 = Zero
            Local7 = Zero
            N018 = 0x04
            N019 = 0x04
            If ((Arg0 == Zero))
            {
                WSMI (0xEA7B, Zero, 0x03, Arg0, Zero)
                If ((AEBX == Zero))
                {
                    DerefOf (N012 [Arg0]) [0x04] = One
                    DerefOf (N012 [Arg0]) [0x03] = Zero
                    DerefOf (N012 [Arg0]) [0x05] = Zero
                }
                Else
                {
                    DerefOf (N012 [Arg0]) [0x04] = Zero
                    DerefOf (N012 [Arg0]) [0x03] = One
                    DerefOf (N012 [Arg0]) [0x05] = One
                }

                N002 = WBUF /* \WBUF */
                CreateField (N002, Zero, (N018 * 0x08), WBU1)
                N003 = WBU1 /* \_SB_.WMID.WQBZ.WBU1 */
                CreateField (N003, Zero, (N018 * 0x08), CBOS)
                While ((Local1 != N018))
                {
                    Local4 = DerefOf (N003 [Local1])
                    Local5 = Zero
                    While ((Local5 != N018))
                    {
                        Local7 = DerefOf (DerefOf (N013 [Local5]) [Zero])
                        If ((Local4 == Local7))
                        {
                            BF01 = DerefOf (DerefOf (N013 [Local5]) [One])
                            N007 = BF01 /* \_SB_.BF01 */
                            N015 [Local6] = N007 /* \_SB_.N007 */
                            Local6++
                            Local5 = (N018 - One)
                        }

                        Local5++
                    }

                    Local1++
                }

                Local0 = Zero
                Local5 = Zero
                Local4 = Zero
                Local0 = 0x0D
                While ((Local5 != N018))
                {
                    BF01 = DerefOf (N015 [Local5])
                    N007 = BF01 /* \_SB_.BF01 */
                    DerefOf (N012 [Zero]) [Local0] = N007 /* \_SB_.N007 */
                    Local5++
                    Local0++
                }

                Local1 = Zero
                Local2 = Zero
                While ((Local2 != N018))
                {
                    BF01 = DerefOf (N015 [Local2])
                    Local5 = Zero
                    While ((DerefOf (BF01 [Local5]) != Zero))
                    {
                        Local3 = DerefOf (BF01 [Local5])
                        N005 [Local1] = Local3
                        Local5++
                        Local1++
                    }

                    N005 [Local1] = 0x2C
                    Local1++
                    Local2++
                }

                Local2 = Zero
                While ((Local2 != 0x09))
                {
                    N005 [Local1] = 0x20
                    Local1++
                    N005 [Local1] = 0x2C
                    Local1++
                    Local2++
                }

                N008 = N005 /* \_SB_.N005 */
                DerefOf (N012 [Zero]) [One] = N008 /* \_SB_.N008 */
            }

            If ((Arg0 == One))
            {
                Local4 = M002 ()
                WSMI (0xEA7B, Zero, 0x08, Arg0, Zero)
                N002 = WBUF /* \WBUF */
                CreateField (N002, Zero, (N019 * 0x08), WBU2)
                N011 = WBU2 /* \_SB_.WMID.WQBZ.WBU2 */
                While ((Local1 != N019))
                {
                    Local4 = DerefOf (N011 [Local1])
                    Local5 = Zero
                    While ((Local5 != N019))
                    {
                        Local7 = DerefOf (DerefOf (N014 [Local5]) [Zero])
                        If ((Local4 == Local7))
                        {
                            BF01 = DerefOf (DerefOf (N014 [Local5]) [One])
                            N007 = BF01 /* \_SB_.BF01 */
                            N016 [Local6] = N007 /* \_SB_.N007 */
                            Local6++
                            Local5 = (N019 - One)
                        }

                        Local5++
                    }

                    Local1++
                }

                Local0 = Zero
                Local5 = Zero
                Local4 = Zero
                Local0 = 0x0D
                While ((Local5 != N019))
                {
                    BF01 = DerefOf (N016 [Local5])
                    N007 = BF01 /* \_SB_.BF01 */
                    DerefOf (N012 [Arg0]) [Local0] = N007 /* \_SB_.N007 */
                    Local5++
                    Local0++
                }

                Local1 = Zero
                Local2 = Zero
                While ((Local2 != N019))
                {
                    BF01 = DerefOf (N016 [Local2])
                    Local5 = Zero
                    While ((DerefOf (BF01 [Local5]) != Zero))
                    {
                        Local3 = DerefOf (BF01 [Local5])
                        N005 [Local1] = Local3
                        Local5++
                        Local1++
                    }

                    N005 [Local1] = 0x2C
                    Local1++
                    Local2++
                }

                Local2 = Zero
                While ((Local2 != 0x09))
                {
                    N005 [Local1] = 0x20
                    Local1++
                    N005 [Local1] = 0x2C
                    Local1++
                    Local2++
                }

                N008 = N005 /* \_SB_.N005 */
                DerefOf (N012 [Arg0]) [One] = N008 /* \_SB_.N008 */
            }

            Return (DerefOf (N012 [Arg0]))
        }

        Method (M001, 1, NotSerialized)
        {
            Local0 = Zero
            WSMI (0xEA7B, Zero, 0x04, Arg0, Zero)
            If ((AEBX == Zero))
            {
                Local0 = AEDX /* \AEDX */
            }

            Return (Local0)
        }

        Method (M003, 0, NotSerialized)
        {
            Local1 = Zero
            Local4 = Zero
            Local5 = Zero
            Local6 = Zero
            Local7 = 0x64
            Local2 = SizeOf (N009)
            Local2--
            While ((Local4 != Local2))
            {
                Local1 = Zero
                While ((Local1 != SizeOf (TEMP)))
                {
                    TEMP [Local1] = Zero
                    Local1++
                }

                Local1 = Zero
                While ((Local1 != 0x28))
                {
                    TEMP [Local1] = DerefOf (N009 [Local4])
                    If (((DerefOf (N009 [Local4]) == 0x2C) || (DerefOf (
                        N009 [Local4]) == Zero)))
                    {
                        Local1 = 0x27
                    }

                    Local1++
                    Local4++
                }

                If ((DerefOf (N009 [Local4]) != Zero))
                {
                    Local3 = FNID ()
                    If ((Local3 != 0xFF))
                    {
                        N004 [Local6] = Local3
                    }

                    Local6++
                }
                Else
                {
                    Local4 = Local2
                }
            }

            Return (Local7)
        }

        Method (FNID, 0, NotSerialized)
        {
            Local3 = 0xFF
            Local2 = One
            If ((SRCM (TEMP, "Internal Hard Drive", 0x13) || SRCM (TEMP, " Internal Hard Drive", 0x14)))
            {
                Local3 = Local2
            }

            Local2++
            If ((SRCM (TEMP, "USB Flash Drive/USB Hard Disk", 0x1D) || SRCM (TEMP, " USB Flash Drive/USB Hard Disk", 0x1E)))
            {
                Local3 = Local2
            }

            Local2++
            If ((SRCM (TEMP, "USB CD/DVD ROM Drive", 0x14) || SRCM (TEMP, " USB CD/DVD ROM Drive", 0x15)))
            {
                Local3 = Local2
            }

            Local2++
            If ((SRCM (TEMP, "Network Adapter", 0x0F) || SRCM (TEMP, " Network Adapter", 0x10)))
            {
                Local3 = Local2
            }

            Return (Local3)
        }

        Method (M004, 0, NotSerialized)
        {
            Local1 = Zero
            Local4 = Zero
            Local5 = Zero
            Local6 = Zero
            Local7 = 0x64
            Local2 = SizeOf (N009)
            Local2--
            While ((Local4 != Local2))
            {
                Local1 = Zero
                While ((Local1 != SizeOf (TEMP)))
                {
                    TEMP [Local1] = Zero
                    Local1++
                }

                Local1 = Zero
                While ((Local1 != 0x28))
                {
                    TEMP [Local1] = DerefOf (N009 [Local4])
                    If (((DerefOf (N009 [Local4]) == 0x2C) || (DerefOf (
                        N009 [Local4]) == Zero)))
                    {
                        Local1 = 0x27
                    }

                    Local1++
                    Local4++
                }

                If ((DerefOf (N009 [Local4]) != Zero))
                {
                    Local3 = UFID ()
                    If ((Local3 != 0xFF))
                    {
                        N004 [Local6] = Local3
                    }

                    Local6++
                }
                Else
                {
                    Local4 = Local2
                }
            }

            Return (Local7)
        }

        Method (UFID, 0, NotSerialized)
        {
            Local3 = 0xFF
            Local2 = One
            If ((SRCM (TEMP, "OS Boot Manager", 0x0F) || SRCM (TEMP, " OS Boot Manager", 0x10)))
            {
                Local3 = Local2
            }

            Local2++
            If ((SRCM (TEMP, "USB Flash Drive/USB Hard Disk", 0x1D) || SRCM (TEMP, " USB Flash Drive/USB Hard Disk", 0x1E)))
            {
                Local3 = Local2
            }

            Local2++
            If ((SRCM (TEMP, "USB CD/DVD ROM Drive", 0x14) || SRCM (TEMP, " USB CD/DVD ROM Drive", 0x15)))
            {
                Local3 = Local2
            }

            Local2++
            If ((SRCM (TEMP, "Network Adapter", 0x0F) || SRCM (TEMP, " Network Adapter", 0x10)))
            {
                Local3 = Local2
            }

            Return (Local3)
        }

        Method (WQBF, 1, NotSerialized)
        {
            Acquire (MUTZ, 0xFFFF)
            Local0 = WQBW (Arg0)
            Release (MUTZ)
            Return (Local0)
        }

        Method (WQBW, 1, NotSerialized)
        {
            If ((M001 (Arg0) == One))
            {
                DerefOf (N00B [Arg0]) [0x06] = Arg0
                DerefOf (N00B [Arg0]) [0x0E] = One
            }
            Else
            {
                DerefOf (N00B [Arg0]) [0x06] = Arg0
                DerefOf (N00B [Arg0]) [0x0E] = Zero
            }

            Return (DerefOf (N00B [Arg0]))
        }

        Method (WQBG, 1, NotSerialized)
        {
            Acquire (MUTZ, 0xFFFF)
            Local0 = WQBV (Arg0)
            Release (MUTZ)
            Return (Local0)
        }

        Method (WQBV, 1, NotSerialized)
        {
            WSMI (0xEA7B, Zero, 0x06, Arg0, Zero)
            If (SRCM (MFLG, "MPMLock", 0x07))
            {
                DerefOf (N00C [Arg0]) [0x03] = One
            }

            Local4 = Zero
            If ((AEBX == Zero))
            {
                Local4 = AEDX /* \AEDX */
            }

            DerefOf (N00C [Arg0]) [0x0E] = Local4
            If ((Local4 <= 0x09))
            {
                Local2 = One
            }
            Else
            {
                Local2 = 0x02
            }

            ToBCD (Local4, Local1)
            Local3 = ISTR (Local1, Local2)
            N007 = Local3
            DerefOf (N00C [Arg0]) [One] = N007 /* \_SB_.N007 */
            Return (DerefOf (N00C [Arg0]))
        }

        Method (WQBH, 0, NotSerialized)
        {
            Acquire (MUTZ, 0xFFFF)
            Release (MUTZ)
        }

        Method (WQBI, 1, NotSerialized)
        {
            Acquire (MUTZ, 0xFFFF)
            Release (MUTZ)
        }

        Method (WQBJ, 1, NotSerialized)
        {
            Acquire (MUTZ, 0xFFFF)
            Release (MUTZ)
        }
    }

    Scope (_SB.WMID)
    {
        Name (LEN2, Zero)
        Method (PSUM, 0, NotSerialized)
        {
            Local0 = Zero
            Local1 = Zero
            While ((Local0 != 0x7F))
            {
                Local1 += DerefOf (N001 [Local0])
                Local0++
            }

            Local1 = (0x0100 - (Local1 & 0xFF))
            N001 [Local0] = (Local1 & 0xFF)
        }

        Method (WMBH, 1, NotSerialized)
        {
            Return (Zero)
        }

        Method (WMBX, 3, NotSerialized)
        {
            M000 ()
            N018 = 0x04
            N019 = 0x04
            If ((Arg1 == One))
            {
                Local0 = Arg2
                Local1 = SizeOf (Local0)
                Local2 = Zero
                Local4 = DerefOf (Local0 [Local2])
                Local2++
                Local4 += (DerefOf (Local0 [Local2]) * 0x0100)
                Local2++
                Local5 = Zero
                Local6 = Zero
                Local3 = Zero
                Local3 = M002 ()
                While ((Local5 != Local4))
                {
                    ST01 [Local6] = DerefOf (Local0 [Local2])
                    Local2++
                    Local5++
                    Local6++
                    Local2++
                    Local5++
                }

                Local4 = DerefOf (Local0 [Local2])
                Local2++
                Local4 += (DerefOf (Local0 [Local2]) * 0x0100)
                Local2++
                Local5 = Zero
                Local6 = Zero
                If ((SRCM (ST01, "Legacy Boot Order", 0x11) || SRCM (ST01, "UEFI Boot Order", 0x0F)))
                {
                    While ((Local5 != Local4))
                    {
                        N009 [Local6] = DerefOf (Local0 [Local2])
                        Local2++
                        Local5++
                        Local6++
                        Local2++
                        Local5++
                    }

                    If ((Local5 == Local4))
                    {
                        Local4 = Zero
                    }
                }

                If (SRCM (ST01, "Setup Password", 0x0E))
                {
                    While ((Local5 != Local4))
                    {
                        N001 [Local6] = DerefOf (Local0 [Local2])
                        Local2++
                        Local5++
                        Local6++
                    }

                    Local4 = DerefOf (Local0 [Local2])
                    Local2++
                    Local4 += (DerefOf (Local0 [Local2]) * 0x0100)
                    Local2++
                    Local5 = Zero
                    Local6 = Zero
                    While ((Local5 != Local4))
                    {
                        N001 [(Local6 + 0x40)] = DerefOf (Local0 [Local2]
                            )
                        Local2++
                        Local5++
                        Local6++
                    }

                    PSUM ()
                    PBUF = N001 /* \_SB_.N001 */
                    WSMI (0xEA7B, One, Zero, 0x0400, Zero)
                    PBUF = ZOBF /* \ZOBF */
                    If ((AEBX == Zero))
                    {
                        N00E [Zero] = Zero
                        Notify (WMID, 0xA0) // Device-Specific
                    }

                    If ((AEBX == 0x06))
                    {
                        N00E [Zero] = One
                        Notify (WMID, 0xA0) // Device-Specific
                    }

                    Return (AEBX) /* \AEBX */
                }

                Local5 = Zero
                Local6 = Zero
                N017 = Local4
                While ((Local5 != Local4))
                {
                    ST02 [Local6] = DerefOf (Local0 [Local2])
                    Local2++
                    Local5++
                    Local6++
                    Local2++
                    Local5++
                }

                LEN2 = Local6
                Local4 = DerefOf (Local0 [Local2])
                Local2++
                Local4 += (DerefOf (Local0 [Local2]) * 0x0100)
                Local2++
                Local5 = Zero
                While ((Local5 != Local4))
                {
                    N001 [Local5] = DerefOf (Local0 [Local2])
                    N001 [(Local5 + 0x40)] = DerefOf (Local0 [Local2]
                        )
                    Local2++
                    Local5++
                }

                PSUM ()
                PBUF = N001 /* \_SB_.N001 */
                WSMI (0xEA7B, One, Zero, 0x0400, Zero)
                PBUF = ZOBF /* \ZOBF */
                If ((AEBX == 0x06))
                {
                    N00E [Zero] = One
                    Notify (WMID, 0xA0) // Device-Specific
                    Return (AEBX) /* \AEBX */
                }

                Local7 = Zero
                Local4 = Zero
                Local2 = Zero
                Local5 = 0x5D
                While ((Local5 != Local4))
                {
                    ST14 = DerefOf (DerefOf (N00A [Local4]) [Zero])
                    If (SRCM (ST01, ST14, SizeOf (ST14)))
                    {
                        Local4 = 0x5D
                        Local4--
                        Local2 = One
                    }

                    Local7++
                    Local4++
                }

                Local7--
                If (SRCM (ST01, "Battery Health Manager", 0x16))
                {
                    If (SRCM (ST02, "Maximize my battery health On", 0x1D))
                    {
                        HPBM = One
                        Notify (BAT0, 0x81) // Information Change
                    }

                    If (SRCM (ST02, "Maximize my battery health Off", 0x1E))
                    {
                        HPBM = Zero
                        Notify (BAT0, 0x81) // Information Change
                    }
                }

                If (SRCM (ST01, "Legacy Boot Order", 0x11))
                {
                    Local2 = 0x03
                }

                If (SRCM (ST01, "UEFI Boot Order", 0x0F))
                {
                    Local2 = 0x08
                }

                If (SRCM (ST01, "Manufacturing Programming Mode Counter", 0x26))
                {
                    Local2 = 0x06
                    Local6 = 0x06
                    Local6 <<= 0x08
                    If ((N017 == 0x04))
                    {
                        CreateByteField (ST02, Zero, HIGB)
                        CreateByteField (ST02, One, LOWB)
                        Local4 = (HIGB - 0x30)
                        Local5 = (LOWB - 0x30)
                        Local4 = (Local5 + (Local4 * 0x0A))
                    }
                    Else
                    {
                        CreateByteField (ST02, Zero, MINL)
                        Local4 = (MINL - 0x30)
                    }

                    If (SRCM (ST01, "Manufacturing Programming Mode Counter", 0x26))
                    {
                        If ((SRCM (MFLG, "MPMLock", 0x07) == Zero))
                        {
                            If (((Local4 >= Zero) && (Local4 <= 0x0A)))
                            {
                                Local4 &= 0xFF
                                Local6 |= Local4
                                FLAG = Zero
                                Local7 = Zero
                                If ((Local4 == 0x0A))
                                {
                                    Local0 = Zero
                                    While ((Local0 < 0x5D))
                                    {
                                        Local5 = DerefOf (DerefOf (N00A [Local0]) [Zero])
                                        If (SCMP (Local5, "Manufacturing Programming Mode"))
                                        {
                                            Break
                                        }

                                        Local0++
                                    }

                                    WSMI (0xEA7B, One, Local0, 0x0100, Zero)
                                }
                            }
                            Else
                            {
                                AEBX = 0x05
                                Return (AEBX) /* \AEBX */
                            }
                        }
                        Else
                        {
                            AEBX = One
                            Return (AEBX) /* \AEBX */
                        }
                    }
                }

                If ((Local2 == Zero))
                {
                    Local7 = Zero
                    Local4 = Zero
                    While ((Local4 < 0x1E))
                    {
                        ST14 = DerefOf (DerefOf (N00D [Local4]) [Zero])
                        If (SRCM (ST01, ST14, SizeOf (ST14)))
                        {
                            Local4 = 0x1E
                            Local2 = 0x02
                        }

                        Local7++
                        Local4++
                    }

                    Local7--
                }

                If ((Local2 == One))
                {
                    FLAG = 0x05
                    Local0 = DerefOf (N00A [Local7])
                    Local1 = 0x0E
                    Local3 = DerefOf (Local0 [0x0D])
                    Local3 += Local1
                    While ((Local1 < Local3))
                    {
                        Local4 = DerefOf (Local0 [Local1])
                        If (SRCM (ST02, Local4, LEN2))
                        {
                            Local6 = (Local1 - 0x0E)
                            FLAG = Zero
                            Break
                        }

                        Local1++
                    }

                    If (SCMP (DerefOf (Local0 [0x0E]), NONO)){}
                    Local6 &= 0xFF
                    Local3 = One
                    Local6 |= (Local3 << 0x08)
                }

                If ((Local2 == 0x02))
                {
                    Local4 = Zero
                    Local5 = 0x02
                    If (SRCM (ST01, "Feature Byte", 0x0C))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = Zero
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "Build ID", 0x08))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = One
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "Serial Number", 0x0D))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x03
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "Product Name", 0x0C))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x04
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "UUID", 0x04))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x06
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "Product Number", SizeOf (ST01)))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x07
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "MAC Address", 0x0B))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x08
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "System Board CT Number", 0x16))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x09
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "MS Digital Marker", 0x11))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x0B
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "SmartAMP R0", 0x0B))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x0C
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "System Family", 0x0D))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x0E
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "Preinstall OS Version", 0x15))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x0F
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "PIN Process Cycle", 0x12))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x12
                        FLAG = Zero
                    }

                    If (SRCM (ST01, "Network Boot TFTP Window Size", 0x1D))
                    {
                        SBUF = ST02 /* \_SB_.ST02 */
                        Local7 = 0x1B
                        FLAG = Zero
                    }

                    Local6 = 0x02
                    Local6 <<= 0x08
                }

                If ((Local2 == 0x03))
                {
                    Local1 = Zero
                    Local2 = Zero
                    Local3 = Zero
                    Local4 = Zero
                    Local5 = Zero
                    Local6 = Zero
                    Local7 = Zero
                    WSMI (0xEA7B, Zero, 0x03, Zero, Zero)
                    N002 = WBUF /* \WBUF */
                    CreateField (N002, Zero, (N018 * 0x08), WBU3)
                    N010 = WBU3 /* \_SB_.WMID.WMBX.WBU3 */
                    Local2 = Zero
                    Local1 = M003 ()
                    N000 = Zero
                    While ((Local2 < 0x64))
                    {
                        Local5 = Zero
                        Local6 = Zero
                        While ((Local6 < N018))
                        {
                            If ((DerefOf (N004 [Local2]) == DerefOf (N010 [Local5])))
                            {
                                N000 = One
                                Local6 = (N018 - One)
                            }

                            Local5++
                            Local6++
                        }

                        Local5--
                        If ((N000 == One))
                        {
                            Local4 = Local5
                            Local4--
                            While ((Local5 > Local3))
                            {
                                N010 [Local5] = DerefOf (N010 [Local4])
                                Local5--
                                Local4--
                            }

                            N010 [Local3] = DerefOf (N004 [Local2])
                            Local3++
                        }

                        Local2++
                        N000 = Zero
                    }

                    WBUF = N010 /* \_SB_.N010 */
                    FLAG = Zero
                    Local7 = Zero
                    Local6 = 0x03
                    Local6 <<= 0x08
                }

                If ((Local2 == 0x08))
                {
                    Local1 = Zero
                    Local2 = Zero
                    Local3 = Zero
                    Local4 = Zero
                    Local5 = Zero
                    Local6 = Zero
                    Local7 = Zero
                    WSMI (0xEA7B, Zero, 0x08, Zero, Zero)
                    N002 = WBUF /* \WBUF */
                    CreateField (N002, Zero, (N019 * 0x08), WBU4)
                    N011 = WBU4 /* \_SB_.WMID.WMBX.WBU4 */
                    Local2 = Zero
                    Local1 = M004 ()
                    N000 = Zero
                    While ((Local2 < 0x64))
                    {
                        Local5 = Zero
                        Local6 = Zero
                        While ((Local6 < N019))
                        {
                            If ((DerefOf (N004 [Local2]) == DerefOf (N011 [Local5])))
                            {
                                N000 = One
                                Local6 = (N019 - One)
                            }

                            Local5++
                            Local6++
                        }

                        Local5--
                        If ((N000 == One))
                        {
                            Local4 = Local5
                            Local4--
                            While ((Local5 > Local3))
                            {
                                N011 [Local5] = DerefOf (N011 [Local4])
                                Local5--
                                Local4--
                            }

                            N011 [Local3] = DerefOf (N004 [Local2])
                            Local3++
                        }

                        Local2++
                        N000 = Zero
                    }

                    WBUF = N011 /* \_SB_.N011 */
                    FLAG = Zero
                    Local7 = Zero
                    Local6 = 0x08
                    Local6 <<= 0x08
                }

                If ((Local2 == Zero))
                {
                    AEBX = One
                    Return (AEBX) /* \AEBX */
                }

                If ((FLAG == 0x05))
                {
                    AEBX = 0x05
                    Return (AEBX) /* \AEBX */
                }

                If ((Local2 != Zero))
                {
                    WSMI (0xEA7B, One, Local7, Local6, Zero)
                    If ((AEBX == Zero))
                    {
                        N00E [Zero] = Zero
                        Notify (WMID, 0xA0) // Device-Specific
                    }

                    If ((AEBX == 0x06))
                    {
                        N00E [Zero] = One
                        Notify (WMID, 0xA0) // Device-Specific
                    }
                }

                Return (AEBX) /* \AEBX */
            }

            If ((Arg1 == 0x02))
            {
                Local3 = M002 ()
                Local0 = Arg2
                Local1 = SizeOf (Local0)
                Local2 = Zero
                Local4 = DerefOf (Local0 [Local2])
                Local2++
                Local4 += (DerefOf (Local0 [Local2]) * 0x0100)
                Local2++
                Local5 = Zero
                While ((Local5 != Local4))
                {
                    N001 [Local5] = DerefOf (Local0 [Local2])
                    N001 [(Local5 + 0x40)] = DerefOf (Local0 [Local2]
                        )
                    Local2++
                    Local5++
                }

                PSUM ()
                PBUF = N001 /* \_SB_.N001 */
                WSMI (0xEA7B, One, Zero, 0x0400, Zero)
                PBUF = ZOBF /* \ZOBF */
                If ((AEBX == 0x06))
                {
                    N00E [Zero] = One
                    Notify (WMID, 0xA0) // Device-Specific
                    Return (AEBX) /* \AEBX */
                }

                WSMI (0xEA7C, Zero, Zero, Zero, Zero)
                If ((AEBX == Zero))
                {
                    N00E [Zero] = Zero
                    Notify (WMID, 0xA0) // Device-Specific
                }

                If ((AEBX == 0x06))
                {
                    N00E [Zero] = One
                    Notify (WMID, 0xA0) // Device-Specific
                }

                Return (AEBX) /* \AEBX */
            }
            Else
            {
                AEBX = 0x05
                Return (AEBX) /* \AEBX */
            }
        }

        Method (WMBA, 3, NotSerialized)
        {
            Acquire (MUTZ, 0xFFFF)
            Local0 = WMBX (Arg0, Arg1, Arg2)
            Release (MUTZ)
            Return (Local0)
        }

        Method (M002, 0, NotSerialized)
        {
            AEBX = 0x05
            Local3 = Zero
            While ((Local3 != SizeOf (ST01)))
            {
                ST01 [Local3] = Zero
                Local3++
            }

            Local3 = Zero
            While ((Local3 != SizeOf (ST02)))
            {
                ST02 [Local3] = Zero
                Local3++
            }

            Local3 = Zero
            While ((Local3 != SizeOf (N009)))
            {
                N009 [Local3] = Zero
                Local3++
            }

            Local3 = Zero
            While ((Local3 != SizeOf (N004)))
            {
                N004 [Local3] = 0xFF
                Local3++
            }

            Local3 = Zero
            While ((Local3 != SizeOf (N001)))
            {
                N001 [Local3] = Zero
                Local3++
            }

            Local3 = Zero
            While ((Local3 != SizeOf (N005)))
            {
                N005 [Local3] = Zero
                Local3++
            }

            Local3 = Zero
            While ((Local3 != SizeOf (BF01)))
            {
                BF01 [Local3] = Zero
                Local3++
            }

            Local3 = Zero
            While ((Local3 != N019))
            {
                N011 [Local3] = Zero
                Local3++
            }

            Return (Zero)
        }

        Method (WMAC, 3, NotSerialized)
        {
            Return (Zero)
        }
    }

    Scope (_SB.PCI0)
    {
        Device (HI04)
        {
            Name (_HID, "HPIC0004")  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }
    }

    Scope (_SB)
    {
        Device (WMPS)
        {
            Name (_HID, "PNP0C14" /* Windows Management Instrumentation Device */)  // _HID: Hardware ID
            Name (_UID, "cPSWMI")  // _UID: Unique ID
            Mutex (MUTZ, 0x00)
            Name (EVTY, Buffer (One)
            {
                 0x00                                             // .
            })
            Name (_WDG, Buffer (0x3C)
            {
                /* 0000 */  0x30, 0x5A, 0x8B, 0x92, 0x7C, 0xAD, 0x36, 0x4C,  // 0Z..|.6L
                /* 0008 */  0x94, 0x6A, 0x13, 0x00, 0xA8, 0x0C, 0xE7, 0xE1,  // .j......
                /* 0010 */  0x43, 0x41, 0x01, 0x02, 0xA3, 0x18, 0x53, 0x8A,  // CA....S.
                /* 0018 */  0x93, 0x73, 0x54, 0x4D, 0x97, 0x9C, 0x89, 0x48,  // .sTM...H
                /* 0020 */  0x35, 0x22, 0xE3, 0x83, 0x80, 0x00, 0x01, 0x08,  // 5"......
                /* 0028 */  0x21, 0x12, 0x90, 0x05, 0x66, 0xD5, 0xD1, 0x11,  // !...f...
                /* 0030 */  0xB2, 0xF0, 0x00, 0xA0, 0xC9, 0x06, 0x29, 0x10,  // ......).
                /* 0038 */  0x43, 0x42, 0x01, 0x00                           // CB..
            })
            Method (PSMF, 2, NotSerialized)
            {
                CreateDWordField (Arg1, Zero, PSIG)
                CreateWordField (Arg1, 0x04, PCML)
                CreateField (Arg1, 0x30, (PCML * 0x08), PCMD)
                If ((Arg0 == One))
                {
                    Local0 = Zero
                    Local1 = Zero
                    Divide ((PCML + 0x02), 0x04, Local1, Local0)
                    If ((Local1 != Zero))
                    {
                        Local0++
                    }

                    Local0 *= 0x04
                    CreateDWordField (Arg1, (Local0 + 0x04), PISZ)
                    CreateByteField (Arg1, (Local0 + 0x08), PD01)
                    CreateWordField (Arg1, (Local0 + 0x08), PD02)
                    CreateDWordField (Arg1, (Local0 + 0x08), PD04)
                }

                If ((Arg0 == 0x02)){}
                Local0 = Zero
                Local0 += 0x04
                If ((Arg0 == One)){}
                If ((Arg0 == 0x02))
                {
                    Local0 += 0x04
                    Local0 += 0x0100
                }

                Local1 = Buffer (Local0)
                    {
                         0x00                                             // .
                    }
                CreateDWordField (Local1, Zero, PSRC)
                PSRC = Zero
                If ((PSIG != 0x57504348))
                {
                    PSRC = 0x02
                    Return (Local1)
                }

                PSRC = 0x03
                If ((Arg0 == One))
                {
                    If (CMCD (PCMD, Unicode ("IntelACA")))
                    {
                        PSRC = Zero
                        If ((PISZ != One))
                        {
                            PSRC = 0x04
                            Return (Local1)
                        }

                        If ((PD01 == Zero)){}
                        ElseIf ((PD01 == One)){}
                        ElseIf ((PD01 == 0x02)){}
                        Else
                        {
                            PSRC = 0x03
                        }
                    }
                }

                If ((Arg0 == 0x02)){}
                Return (Local1)
            }

            Method (CMCD, 2, NotSerialized)
            {
                Local0 = (SizeOf (Arg0) + 0x02)
                If ((Local0 < SizeOf (Arg1)))
                {
                    Return (Zero)
                }

                Name (BUF0, Buffer (Local0)
                {
                     0x00                                             // .
                })
                Name (BUF1, Buffer (Local0)
                {
                     0x00                                             // .
                })
                BUF0 = Arg0
                BUF1 = Arg1
                While (Local0)
                {
                    Local0--
                    If ((DerefOf (BUF0 [Local0]) != DerefOf (BUF1 [Local0]
                        )))
                    {
                        Return (Zero)
                    }
                }

                Return (One)
            }

            Method (ACAS, 0, NotSerialized)
            {
                Local0 = Zero
                If ((^^WMID.WTPS == 0x05))
                {
                    Local0 = One
                }

                Return (Local0)
            }

            Method (WMCA, 3, Serialized)
            {
                Acquire (MUTZ, 0xFFFF)
                Local0 = PSMF (Arg1, Arg2)
                Release (MUTZ)
                Return (Local0)
            }

            Method (_WED, 1, NotSerialized)  // _Wxx: Wake Event, xx=0x00-0xFF
            {
                If ((Arg0 == 0x80))
                {
                    Local0 = Buffer (0x08)
                        {
                             0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   // ........
                        }
                    CreateDWordField (Local0, Zero, PEID)
                    CreateDWordField (Local0, 0x04, PEDA)
                    If ((DerefOf (EVTY [Zero]) == One))
                    {
                        PEID = One
                        PEDA = ACAS ()
                    }

                    If ((DerefOf (EVTY [Zero]) == Zero))
                    {
                        PEID = 0xFF
                        PEDA = 0xFFFF
                    }

                    Return (Local0)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Name (WQCB, Buffer (0x048F)
            {
                /* 0000 */  0x46, 0x4F, 0x4D, 0x42, 0x01, 0x00, 0x00, 0x00,  // FOMB....
                /* 0008 */  0x7F, 0x04, 0x00, 0x00, 0x4C, 0x12, 0x00, 0x00,  // ....L...
                /* 0010 */  0x44, 0x53, 0x00, 0x01, 0x1A, 0x7D, 0xDA, 0x54,  // DS...}.T
                /* 0018 */  0x28, 0xD6, 0x88, 0x00, 0x01, 0x06, 0x18, 0x42,  // (......B
                /* 0020 */  0x10, 0x05, 0x10, 0x8A, 0x21, 0x83, 0x42, 0x04,  // ....!.B.
                /* 0028 */  0x92, 0x43, 0xA4, 0xB8, 0x44, 0x86, 0xA1, 0x16,  // .C..D...
                /* 0030 */  0x40, 0x0C, 0x21, 0x17, 0x4C, 0x4C, 0x80, 0x08,  // @.!.LL..
                /* 0038 */  0x08, 0x79, 0x15, 0x60, 0x53, 0x80, 0x49, 0x10,  // .y.`S.I.
                /* 0040 */  0xF5, 0xEF, 0x0F, 0x51, 0x12, 0x1C, 0x4A, 0x08,  // ...Q..J.
                /* 0048 */  0x84, 0x24, 0x0A, 0x30, 0x2F, 0x40, 0xB7, 0x00,  // .$.0/@..
                /* 0050 */  0xC3, 0x02, 0x6C, 0x0B, 0x30, 0x2D, 0xC0, 0x31,  // ..l.0-.1
                /* 0058 */  0x24, 0x95, 0x06, 0x4E, 0x09, 0x2C, 0x05, 0x42,  // $..N.,.B
                /* 0060 */  0x42, 0x05, 0x28, 0x17, 0xE0, 0x5B, 0x80, 0x76,  // B.(..[.v
                /* 0068 */  0x44, 0x49, 0x16, 0x60, 0x19, 0x46, 0x04, 0x1E,  // DI.`.F..
                /* 0070 */  0x45, 0x64, 0xA3, 0x71, 0x68, 0xEC, 0x30, 0x2C,  // Ed.qh.0,
                /* 0078 */  0x13, 0x4C, 0x83, 0x38, 0x8C, 0xB2, 0x91, 0x45,  // .L.8...E
                /* 0080 */  0xE0, 0x09, 0x75, 0x2A, 0x40, 0xAE, 0x00, 0x61,  // ..u*@..a
                /* 0088 */  0x02, 0xC4, 0xA3, 0x0A, 0xA3, 0x39, 0x28, 0x02,  // .....9(.
                /* 0090 */  0x17, 0x1A, 0xB3, 0x47, 0x7B, 0x16, 0x60, 0x7D,  // ...G{.`}
                /* 0098 */  0x24, 0x84, 0xC0, 0xEE, 0x21, 0xA5, 0x4C, 0x80,  // $...!.L.
                /* 00A0 */  0x38, 0x01, 0x8A, 0x05, 0x58, 0x9B, 0x81, 0x9C,  // 8...X...
                /* 00A8 */  0x41, 0xCB, 0x16, 0x88, 0xE0, 0x7A, 0x9B, 0x85,  // A....z..
                /* 00B0 */  0x50, 0x8E, 0x20, 0x46, 0xA8, 0xDA, 0x50, 0x84,  // P. F..P.
                /* 00B8 */  0x19, 0x26, 0x48, 0xB4, 0x28, 0x8D, 0x61, 0x12,  // .&H.(.a.
                /* 00C0 */  0x84, 0x30, 0xB1, 0x63, 0x04, 0x3C, 0x9C, 0xB0,  // .0.c.<..
                /* 00C8 */  0x21, 0x62, 0xB5, 0x3F, 0x08, 0x12, 0x70, 0xDC,  // !b.?..p.
                /* 00D0 */  0x92, 0x00, 0xA2, 0x48, 0xA3, 0x41, 0x8D, 0x35,  // ...H.A.5
                /* 00D8 */  0xC1, 0xB1, 0x7B, 0xDC, 0x27, 0xDC, 0xB9, 0x00,  // ..{.'...
                /* 00E0 */  0xE9, 0xE8, 0x02, 0x09, 0x6E, 0x9D, 0x83, 0x26,  // ....n..&
                /* 00E8 */  0xC3, 0x63, 0x58, 0x09, 0x3A, 0x38, 0x05, 0x40,  // .cX.:8.@
                /* 00F0 */  0x71, 0x0D, 0xA8, 0xE9, 0x1F, 0x3C, 0x13, 0x04,  // q....<..
                /* 00F8 */  0x87, 0x1A, 0xA2, 0x47, 0x1D, 0xEE, 0xD8, 0x3C,  // ...G...<
                /* 0100 */  0x12, 0x06, 0x71, 0x4E, 0xC7, 0x8D, 0x75, 0x38,  // ..qN..u8
                /* 0108 */  0x19, 0x0D, 0xBA, 0x54, 0x01, 0x66, 0x0F, 0x00,  // ...T.f..
                /* 0110 */  0xB2, 0x08, 0xA4, 0xF1, 0x18, 0xFA, 0x74, 0xCF,  // ......t.
                /* 0118 */  0xE7, 0x84, 0x13, 0x58, 0xFE, 0x20, 0x50, 0x23,  // ...X. P#
                /* 0120 */  0xF3, 0xFF, 0x1F, 0xDA, 0x06, 0xA7, 0x25, 0xCC,  // ......%.
                /* 0128 */  0x90, 0xCF, 0x02, 0x87, 0xC5, 0xC4, 0x1E, 0x19,  // ........
                /* 0130 */  0xE8, 0x78, 0xC0, 0x7F, 0x10, 0x78, 0x34, 0x88,  // .x...x4.
                /* 0138 */  0xF0, 0x66, 0xE0, 0xF9, 0xFA, 0xAC, 0x60, 0x60,  // .f....``
                /* 0140 */  0xEC, 0x80, 0xEC, 0x57, 0x00, 0x42, 0xF0, 0x97,  // ...W.B..
                /* 0148 */  0x84, 0x23, 0x7A, 0x42, 0x88, 0x90, 0xA0, 0x68,  // .#zB...h
                /* 0150 */  0x01, 0xC2, 0x81, 0x04, 0x71, 0x78, 0x71, 0x5F,  // ....qxq_
                /* 0158 */  0x0E, 0x4E, 0xA0, 0x47, 0x7C, 0x8D, 0x2B, 0x5A,  // .N.G|.+Z
                /* 0160 */  0x0C, 0x83, 0x9D, 0xC3, 0xF1, 0x47, 0x38, 0x07,  // .....G8.
                /* 0168 */  0xCF, 0xC8, 0x22, 0x07, 0x81, 0x12, 0x33, 0x08,  // .."...3.
                /* 0170 */  0xD4, 0x49, 0xE0, 0x1C, 0x0E, 0xE9, 0x84, 0x62,  // .I.....b
                /* 0178 */  0x1F, 0x41, 0x94, 0xD8, 0xC7, 0xE4, 0x33, 0x84,  // .A....3.
                /* 0180 */  0x11, 0x8E, 0xE0, 0xD1, 0xE1, 0x51, 0xC2, 0x9A,  // .....Q..
                /* 0188 */  0x47, 0xA0, 0x79, 0x9C, 0xD6, 0x0B, 0x81, 0x09,  // G.y.....
                /* 0190 */  0xC6, 0x31, 0x31, 0x58, 0x16, 0xF0, 0x85, 0x20,  // .11X... 
                /* 0198 */  0x1B, 0xAB, 0x35, 0x81, 0x44, 0x8D, 0xD6, 0x40,  // ..5.D..@
                /* 01A0 */  0x1A, 0x14, 0x7E, 0x4A, 0xB0, 0x08, 0x46, 0x7E,  // ..~J..F~
                /* 01A8 */  0x22, 0xE8, 0x00, 0xC2, 0xC3, 0xC2, 0x28, 0x2A,  // ".....(*
                /* 01B0 */  0x89, 0x06, 0x65, 0x38, 0x87, 0x83, 0x11, 0x9C,  // ..e8....
                /* 01B8 */  0x41, 0x7C, 0x02, 0x71, 0x0A, 0x08, 0x39, 0x39,  // A|.q..99
                /* 01C0 */  0x11, 0xA0, 0x74, 0x80, 0x68, 0x18, 0x0F, 0x04,  // ..t.h...
                /* 01C8 */  0x2F, 0x06, 0xE7, 0xF0, 0xF0, 0xE0, 0xD9, 0xF8,  // /.......
                /* 01D0 */  0xDA, 0xC0, 0x66, 0xE9, 0x0B, 0x01, 0xD7, 0x70,  // ..f....p
                /* 01D8 */  0x87, 0x20, 0xE3, 0x0C, 0x6D, 0x35, 0x80, 0x14,  // . ..m5..
                /* 01E0 */  0x0C, 0x73, 0x16, 0x49, 0xC0, 0x74, 0x9D, 0x0A,  // .s.I.t..
                /* 01E8 */  0xA0, 0xDF, 0x38, 0x3C, 0x91, 0x13, 0x7C, 0xC8,  // ..8<..|.
                /* 01F0 */  0x78, 0xE1, 0x78, 0x55, 0x91, 0x80, 0xFF, 0xFF,  // x.xU....
                /* 01F8 */  0xE5, 0x02, 0x8B, 0xCC, 0xC6, 0x89, 0x1D, 0x13,  // ........
                /* 0200 */  0x58, 0x07, 0xEB, 0x31, 0xC1, 0x3F, 0x57, 0x60,  // X..1.?W`
                /* 0208 */  0x93, 0xCC, 0x1A, 0xAD, 0xE5, 0x02, 0x43, 0x66,  // ......Cf
                /* 0210 */  0xF4, 0xFC, 0xE1, 0x79, 0x5B, 0xFD, 0x75, 0x40,  // ...y[.u@
                /* 0218 */  0xF3, 0x06, 0xF7, 0xB5, 0xC0, 0xF3, 0x06, 0x5B,  // .......[
                /* 0220 */  0x4A, 0x08, 0x19, 0x39, 0x34, 0xD0, 0x49, 0xF1,  // J..94.I.
                /* 0228 */  0x43, 0x83, 0x8D, 0x0B, 0x50, 0x38, 0x2D, 0xC4,  // C...P8-.
                /* 0230 */  0xA4, 0x58, 0x20, 0x08, 0x5D, 0x58, 0x3C, 0x29,  // .X .]X<)
                /* 0238 */  0x78, 0xEA, 0x6E, 0x3B, 0xE8, 0x8B, 0x0E, 0x9B,  // x.n;....
                /* 0240 */  0x25, 0x66, 0xCA, 0xC7, 0x0A, 0x6F, 0x8C, 0xB0,  // %f...o..
                /* 0248 */  0x90, 0x2C, 0x6B, 0x8C, 0xA0, 0xB9, 0xDC, 0x24,  // .,k....$
                /* 0250 */  0xA8, 0xEF, 0x3A, 0x02, 0xF1, 0xFF, 0x7F, 0x1D,  // ..:.....
                /* 0258 */  0xC1, 0x00, 0xF9, 0xF0, 0x61, 0xA5, 0xF7, 0x0F,  // ....a...
                /* 0260 */  0x3A, 0x85, 0x10, 0x61, 0xA2, 0x19, 0x9D, 0xBF,  // :..a....
                /* 0268 */  0x12, 0x7C, 0xCA, 0xE0, 0x91, 0x4F, 0x0A, 0x14,  // .|...O..
                /* 0270 */  0xC4, 0xD7, 0x00, 0xC7, 0xB9, 0x1F, 0xA0, 0xA7,  // ........
                /* 0278 */  0x6C, 0xFC, 0x67, 0x0F, 0x0F, 0xE9, 0x49, 0xE1,  // l.g...I.
                /* 0280 */  0x90, 0xDE, 0x22, 0x7C, 0x1D, 0x31, 0x81, 0x2F,  // .."|.1./
                /* 0288 */  0x00, 0x8F, 0x3B, 0xB0, 0x7C, 0x0A, 0xB0, 0x3A,  // ..;.|..:
                /* 0290 */  0x1B, 0x9D, 0x63, 0x18, 0x9C, 0x87, 0xCB, 0xE1,  // ..c.....
                /* 0298 */  0x7C, 0xD1, 0xE0, 0x37, 0x01, 0x1F, 0x67, 0xE0,  // |..7..g.
                /* 02A0 */  0xDF, 0x10, 0xB0, 0x04, 0x05, 0xCE, 0x17, 0xE4,  // ........
                /* 02A8 */  0xF0, 0x98, 0x9B, 0x02, 0xBF, 0x0E, 0x78, 0x5C,  // ......x\
                /* 02B0 */  0x7C, 0xA8, 0xBE, 0x23, 0x30, 0xEC, 0x73, 0xF5,  // |..#0.s.
                /* 02B8 */  0xC1, 0xE1, 0x50, 0x3D, 0xA8, 0xD7, 0x0F, 0x0F,  // ..P=....
                /* 02C0 */  0xDC, 0xB0, 0x1E, 0x29, 0x87, 0x35, 0x5A, 0xD8,  // ...).5Z.
                /* 02C8 */  0x03, 0x7E, 0xEA, 0xF1, 0x8D, 0xC9, 0x33, 0x33,  // .~....33
                /* 02D0 */  0x46, 0x58, 0x9F, 0x95, 0xC0, 0x01, 0x88, 0xF7,  // FX......
                /* 02D8 */  0x7E, 0xFF, 0x20, 0x13, 0x30, 0x20, 0x8B, 0x7A,  // ~. .0 .z
                /* 02E0 */  0xC0, 0x41, 0x0B, 0x3A, 0xE0, 0x40, 0x39, 0x04,  // .A.:.@9.
                /* 02E8 */  0xB1, 0x93, 0x0A, 0xE6, 0xFF, 0x7F, 0xC0, 0xE1,  // ........
                /* 02F0 */  0xE1, 0x0F, 0x38, 0xA8, 0xD8, 0x30, 0x12, 0x7F,  // ..8..0..
                /* 02F8 */  0x56, 0x40, 0xC9, 0x85, 0x11, 0x9C, 0x41, 0x3C,  // V@....A<
                /* 0300 */  0x5C, 0x1F, 0x70, 0x00, 0x56, 0x9C, 0x44, 0x80,  // \.p.V.D.
                /* 0308 */  0x85, 0xF0, 0xE3, 0x13, 0x4A, 0xEA, 0xF1, 0x89,  // ....J...
                /* 0310 */  0x82, 0xF8, 0x38, 0xE1, 0x93, 0x08, 0x70, 0xFA,  // ..8...p.
                /* 0318 */  0xFF, 0x9F, 0x44, 0xE0, 0x9C, 0x18, 0x7C, 0x12,  // ..D...|.
                /* 0320 */  0x01, 0xDF, 0xB8, 0xE0, 0x5C, 0x72, 0xF0, 0xE3,  // ....\r..
                /* 0328 */  0x89, 0xFD, 0x32, 0xE6, 0x71, 0x81, 0x1B, 0xCA,  // ..2.q...
                /* 0330 */  0xE3, 0x02, 0x5F, 0xD4, 0x23, 0x12, 0x7A, 0x5C,  // .._.#.z\
                /* 0338 */  0x3E, 0x22, 0xE1, 0xC7, 0xC5, 0x43, 0x9D, 0x54,  // >"...C.T
                /* 0340 */  0xE8, 0xB8, 0xE0, 0xCA, 0xBB, 0x23, 0x81, 0x72,  // .....#.r
                /* 0348 */  0x20, 0xFC, 0x98, 0x03, 0xF7, 0x92, 0x04, 0xAE,  //  .......
                /* 0350 */  0x53, 0x0E, 0xF0, 0xF8, 0xFF, 0x9F, 0x72, 0xC0,  // S.....r.
                /* 0358 */  0x77, 0x6E, 0xF0, 0x29, 0x07, 0xB8, 0x86, 0x5B,  // wn.)...[
                /* 0360 */  0x97, 0x0F, 0xB4, 0x34, 0x0E, 0x0C, 0xEA, 0x4C,  // ...4...L
                /* 0368 */  0x0B, 0x98, 0xBC, 0x23, 0xC4, 0x7F, 0xA4, 0x7D,  // ...#...}
                /* 0370 */  0xB6, 0x78, 0x87, 0x8D, 0x62, 0x90, 0x77, 0xD9,  // .x..b.w.
                /* 0378 */  0xE7, 0xD8, 0x18, 0xD1, 0xA3, 0x78, 0x04, 0x31,  // .....x.1
                /* 0380 */  0xC3, 0xC5, 0x78, 0xA6, 0x35, 0x56, 0x88, 0x07,  // ..x.5V..
                /* 0388 */  0x5B, 0x63, 0x3E, 0xD6, 0x1A, 0x23, 0x60, 0xB4,  // [c>..#`.
                /* 0390 */  0x07, 0x8D, 0x08, 0x87, 0x13, 0x25, 0x8E, 0xCF,  // .....%..
                /* 0398 */  0xB4, 0x2C, 0xC0, 0x0B, 0x41, 0x1E, 0xCE, 0xB4,  // .,..A...
                /* 03A0 */  0xA0, 0xFA, 0xFF, 0x9F, 0x69, 0x01, 0xEF, 0x11,  // ....i...
                /* 03A8 */  0x0F, 0x37, 0x68, 0x68, 0x83, 0x9E, 0x8D, 0x0F,  // .7hh....
                /* 03B0 */  0x18, 0xBE, 0x95, 0xB0, 0x73, 0x07, 0x3F, 0x83,  // ....s.?.
                /* 03B8 */  0xF9, 0xDC, 0xC1, 0x0F, 0x2B, 0x98, 0x0B, 0x23,  // ....+..#
                /* 03C0 */  0xE6, 0xAC, 0xC6, 0xCF, 0x1A, 0xE0, 0x3F, 0xE6,  // ......?.
                /* 03C8 */  0x80, 0x2F, 0xE4, 0x08, 0xD1, 0xE3, 0xF2, 0x08,  // ./......
                /* 03D0 */  0x31, 0x03, 0xE3, 0x43, 0x84, 0xFD, 0xFF, 0x1F,  // 1..C....
                /* 03D8 */  0x22, 0xFE, 0x2C, 0x00, 0x8E, 0x21, 0x02, 0x9F,  // ".,..!..
                /* 03E0 */  0x33, 0x0E, 0x38, 0x8E, 0x78, 0xF8, 0xA1, 0x62,  // 3.8.x..b
                /* 03E8 */  0x8E, 0xCC, 0xC0, 0xE4, 0xB4, 0xE0, 0x21, 0xF0,  // ......!.
                /* 03F0 */  0x23, 0x87, 0x87, 0xC0, 0x07, 0xF0, 0xBC, 0x74,  // #......t
                /* 03F8 */  0x7A, 0x3E, 0xFF, 0x9C, 0x14, 0xEE, 0x00, 0xC0,  // z>......
                /* 0400 */  0xA7, 0x84, 0x1B, 0x00, 0x46, 0xA1, 0x4D, 0x9F,  // ....F.M.
                /* 0408 */  0x1A, 0x8D, 0x5A, 0x35, 0x28, 0x53, 0xA3, 0x4C,  // ..Z5(S.L
                /* 0410 */  0x83, 0x5A, 0x7D, 0x2A, 0x35, 0x66, 0x6C, 0x10,  // .Z}*5fl.
                /* 0418 */  0x3E, 0xBA, 0xFB, 0x40, 0x60, 0x79, 0x2F, 0x01,  // >..@`y/.
                /* 0420 */  0x81, 0x38, 0x1B, 0x85, 0x8C, 0x80, 0x28, 0x28,  // .8....((
                /* 0428 */  0x88, 0x80, 0xAC, 0xF0, 0x65, 0x20, 0x20, 0xCB,  // ....e  .
                /* 0430 */  0x05, 0x11, 0x90, 0x0F, 0x89, 0x06, 0x72, 0x6E,  // ......rn
                /* 0438 */  0x20, 0xAA, 0xF9, 0xB5, 0xA3, 0xA3, 0x84, 0x03,  //  .......
                /* 0440 */  0x81, 0x08, 0xCC, 0xE9, 0x40, 0x04, 0xE6, 0x30,  // ....@..0
                /* 0448 */  0xBF, 0x3B, 0x01, 0x39, 0x1A, 0x88, 0x80, 0xAC,  // .;.9....
                /* 0450 */  0x7D, 0x45, 0x02, 0x72, 0x10, 0x10, 0x01, 0x59,  // }E.r...Y
                /* 0458 */  0xC1, 0x41, 0x5B, 0x40, 0x96, 0x03, 0x22, 0x20,  // .A[@.." 
                /* 0460 */  0xC7, 0x07, 0xA2, 0x62, 0x54, 0x40, 0xFC, 0xFF,  // ...bT@..
                /* 0468 */  0x0F, 0x80, 0x80, 0x68, 0x00, 0x04, 0x88, 0x4A,  // ...h...J
                /* 0470 */  0x7B, 0x27, 0x68, 0x28, 0x16, 0x0E, 0x22, 0x30,  // {'h(.."0
                /* 0478 */  0xC7, 0x00, 0x11, 0x98, 0x65, 0x3E, 0x15, 0x05,  // ....e>..
                /* 0480 */  0xE2, 0x90, 0x20, 0x34, 0x86, 0x0F, 0x10, 0x26,  // .. 4...&
                /* 0488 */  0xF5, 0x75, 0x20, 0x10, 0xFF, 0xFF, 0x01         // .u ....
            })
        }
    }

    Scope (\)
    {
        OperationRegion (OEPM, SystemMemory, 0xFF802089, 0x04)
        Field (OEPM, AnyAcc, Lock, Preserve)
        {
            PFRV,   24
        }

        OperationRegion (QCMS, SystemIO, 0x72, 0x02)
        Field (QCMS, ByteAcc, NoLock, Preserve)
        {
            QCMI,   8, 
            QCMD,   8
        }

        IndexField (QCMI, QCMD, ByteAcc, NoLock, Preserve)
        {
            Offset (0xE1), 
            WBPB,   1, 
            WBRC,   1, 
            WBLN,   1, 
            WBUB,   1
        }

        Method (CKPT, 4, NotSerialized)
        {
            Local0 = PFRV /* \PFRV */
            If (((Local0 == 0x00FFFFFF) || (Local0 == Zero)))
            {
                Return (Zero)
            }

            Local1 = (Local0 & 0xFF)
            If ((ISDG (Local1) != One))
            {
                Return (Zero)
            }

            Local1 -= 0x30
            Local2 = (Local0 >> 0x08)
            Local2 &= 0xFF
            If ((ISDG (Local2) != One))
            {
                Return (Zero)
            }

            Local2 -= 0x30
            Local3 = (Local0 >> 0x10)
            Local3 &= 0xFF
            If ((ISDG (Local3) != One))
            {
                Return (Zero)
            }

            Local3 -= 0x30
            If ((Arg3 & One))
            {
                If ((Arg0 == Local1))
                {
                    If ((Arg1 == Local2))
                    {
                        If ((Arg2 == Local3))
                        {
                            Return (One)
                        }
                    }
                }
            }

            If ((Arg3 & 0x02))
            {
                If ((Local1 >= Arg0))
                {
                    If ((Local1 > Arg0))
                    {
                        Return (One)
                    }

                    If ((Local2 >= Arg1))
                    {
                        If ((Local2 > Arg1))
                        {
                            Return (One)
                        }

                        If ((Local3 > Arg2))
                        {
                            Return (One)
                        }
                    }
                }
            }

            If ((Arg3 & 0x04))
            {
                If ((Local1 <= Arg0))
                {
                    If ((Local1 < Arg0))
                    {
                        Return (One)
                    }

                    If ((Local2 <= Arg1))
                    {
                        If ((Local2 < Arg1))
                        {
                            Return (One)
                        }

                        If ((Local3 < Arg2))
                        {
                            Return (One)
                        }
                    }
                }
            }

            Return (Zero)
        }

        Method (ISDG, 1, NotSerialized)
        {
            Local0 = Arg0
            If (((Local0 <= 0x39) && (Local0 >= 0x30)))
            {
                Return (One)
            }

            Return (Zero)
        }
    }

    Scope (_SB)
    {
        Method (POSW, 1, NotSerialized)
        {
            If ((Arg0 & 0x8000))
            {
                If ((Arg0 == 0xFFFF))
                {
                    Return (Ones)
                }
                Else
                {
                    Local0 = ~Arg0
                    Local0++
                    Local0 &= 0xFFFF
                    Return (Local0)
                }
            }
            Else
            {
                Return (Arg0)
            }
        }

        Method (GBFE, 3, NotSerialized)
        {
            CreateByteField (Arg0, Arg1, TIDX)
            Arg2 = TIDX /* \_SB_.GBFE.TIDX */
        }

        Method (PBFE, 3, NotSerialized)
        {
            CreateByteField (Arg0, Arg1, TIDX)
            TIDX = Arg2
        }

        Method (ITOS, 1, NotSerialized)
        {
            Local0 = Buffer (0x05)
                {
                     0x20, 0x20, 0x20, 0x20, 0x20                     //      
                }
            Local7 = Buffer (0x11)
                {
                    "0123456789ABCDEF"
                }
            Local1 = 0x05
            Local2 = Zero
            Local3 = Zero
            While (Local1)
            {
                Local1--
                Local4 = ((Arg0 >> (Local1 << 0x02)) & 0x0F)
                GBFE (Local7, Local4, RefOf (Local5))
                PBFE (Local0, Local2, Local5)
                Local2++
            }

            Return (Local0)
        }

        Method (ERHO, 0, NotSerialized)
        {
            If ((OSVR == 0x03))
            {
                Return (One)
            }
            Else
            {
                Return (Zero)
            }
        }

        Method (ESUO, 0, NotSerialized)
        {
            Return (Zero)
        }

        Method (VTOS, 0, NotSerialized)
        {
            If ((OSVR >= 0x0C))
            {
                Return (One)
            }
            Else
            {
                Return (Zero)
            }
        }

        Method (W7OS, 0, NotSerialized)
        {
            If ((OSVR >= 0x0E))
            {
                Return (One)
            }
            Else
            {
                Return (Zero)
            }
        }

        Method (W8OS, 0, NotSerialized)
        {
            If ((OSVR >= 0x0F))
            {
                Return (One)
            }
            Else
            {
                Return (Zero)
            }
        }

        Method (W81O, 0, NotSerialized)
        {
            If ((OSVR >= 0x10))
            {
                Return (One)
            }
            Else
            {
                Return (Zero)
            }
        }

        Method (NVPT, 1, NotSerialized)
        {
            Notify (NPCF, 0xC0) // Hardware-Specific
        }
    }

    Scope (_SB)
    {
        OperationRegion (ERMM, SystemMemory, 0xFED80000, 0x1800)
        Field (ERMM, AnyAcc, NoLock, Preserve)
        {
            Offset (0x244), 
            SMP4,   8, 
            Offset (0x278), 
            XHP0,   5, 
            Offset (0x279), 
            XHP1,   5, 
            Offset (0x27A), 
            Offset (0x1500)
        }

        Method (DPTC, 2, Serialized)
        {
            Name (DPTI, Buffer (0x07){})
            CreateWordField (DPTI, Zero, SSZE)
            CreateByteField (DPTI, 0x02, SMUF)
            CreateDWordField (DPTI, 0x03, DATA)
            SSZE = 0x07
            SMUF = Arg0
            DATA = Arg1
            ALIB (0x0C, DPTI)
            Sleep (0x64)
        }

        Name (TC20, Zero)
        Name (TC21, Zero)
        Name (TC22, Zero)
        Name (TC23, Zero)
        Name (TC24, Zero)
        Name (TC25, Zero)
        Name (TC26, Zero)
        Name (TC27, Zero)
        Name (TC28, Zero)
        Name (TC29, Zero)
        Name (TC2A, Zero)
        Name (TC2B, Zero)
        Name (TC2C, Zero)
        Name (TC2D, Zero)
        Name (TC2E, Zero)
        Name (DC20, Zero)
        Name (DC21, Zero)
        Name (DC22, Zero)
        Name (DC23, Zero)
        Name (DC24, Zero)
        Name (DC25, Zero)
        Name (DC26, Zero)
        Name (DC27, Zero)
        Name (DC28, Zero)
        Name (DC29, Zero)
        Name (DC2A, Zero)
        Name (DC2B, Zero)
        Name (DC2C, Zero)
        Name (DC2D, Zero)
        Name (DC2E, Zero)
        Method (STTR, 1, NotSerialized)
        {
            Local0 = 0xAFC8
            If ((Local0 != DC2E))
            {
                DPTC (0x2E, Local0)
                DC2E = Local0
            }
        }
    }

    Scope (_SB)
    {
        Device (BAT0)
        {
            Method (ATOW, 1, NotSerialized)
            {
                Local0 = Zero
                If (^^PCI0.SBRG.EC0.RA40)
                {
                    Local3 = ^^PCI0.SBRG.EC0.R740 /* \_SB_.PCI0.SBRG.EC0_.R740 */
                    Local0 = (Arg0 * Local3)
                    Local0 /= 0x03E8
                }

                Return (Local0)
            }

            Method (WTOA, 1, NotSerialized)
            {
                Local0 = Zero
                If (^^PCI0.SBRG.EC0.RA40)
                {
                    Local0 = (Arg0 * 0x03E8)
                    Local3 = ^^PCI0.SBRG.EC0.R740 /* \_SB_.PCI0.SBRG.EC0_.R740 */
                    Local0 /= Local3
                }

                Return (Local0)
            }

            Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)  // _HID: Hardware ID
            Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
            {
                _SB, 
            })
            Name (PBST, Package (0x04)
            {
                Zero, 
                Ones, 
                Ones, 
                Ones
            })
            Name (PBIF, Package (0x0D)
            {
                One, 
                Ones, 
                Ones, 
                One, 
                Ones, 
                0x19B4, 
                0x1086, 
                0x01A7, 
                0x75, 
                "BAT1", 
                " ", 
                " ", 
                " "
            })
            Name (PBIX, Package (0x14)
            {
                Zero, 
                Zero, 
                0xFFFFFFFF, 
                0xFFFFFFFF, 
                Zero, 
                0xFFFFFFFF, 
                0x0A, 
                0x05, 
                Zero, 
                0x00017318, 
                0x61A8, 
                0x3A98, 
                0x88B8, 
                0x61A8, 
                0x0A, 
                0x19, 
                "BAT0", 
                " ", 
                " ", 
                " "
            })
            Name (BATB, 0x0F)
            Name (FBAS, 0x0B)
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    If (^^PCI0.SBRG.EC0.RA40)
                    {
                        Local0 = 0x1F
                    }
                    Else
                    {
                        Local0 = 0x0F
                    }
                }
                Else
                {
                    Local0 = BATB /* \_SB_.BAT0.BATB */
                }

                BATB = Local0
                Return (Local0)
            }

            Method (_BST, 0, NotSerialized)  // _BST: Battery Status
            {
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    If (^^PCI0.SBRG.EC0.RA40)
                    {
                        UPBS ()
                    }
                    Else
                    {
                        IVBS ()
                    }
                }
                Else
                {
                    IVBS ()
                }

                If ((BRTM == Zero))
                {
                    PBST [One] = 0xFFFFFFFF
                }

                Return (PBST) /* \_SB_.BAT0.PBST */
            }

            Method (_BTP, 1, NotSerialized)  // _BTP: Battery Trip Point
            {
                If ((Arg0 == Zero))
                {
                    ^^PCI0.SBRG.EC0.BTPL = Zero
                    ^^PCI0.SBRG.EC0.BTPH = Zero
                }
                Else
                {
                    Local0 = Arg0
                    Local1 = WTOA (Local0)
                    ^^PCI0.SBRG.EC0.BTPL = (Local1 & 0xFF)
                    ^^PCI0.SBRG.EC0.BTPH = ((Local1 & 0xFF00) >> 0x08)
                }
            }

            Method (_BIF, 0, NotSerialized)  // _BIF: Battery Information
            {
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    If (^^PCI0.SBRG.EC0.RA40)
                    {
                        UPBI ()
                    }
                    Else
                    {
                        IVBI ()
                    }
                }
                Else
                {
                    IVBI ()
                }

                Return (PBIF) /* \_SB_.BAT0.PBIF */
            }

            Method (_BIX, 0, NotSerialized)  // _BIX: Battery Information Extended
            {
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    If (^^PCI0.SBRG.EC0.RA40)
                    {
                        UPBX ()
                    }
                    Else
                    {
                        IVBX ()
                    }
                }
                Else
                {
                    IVBX ()
                }

                Return (PBIX) /* \_SB_.BAT0.PBIX */
            }

            Method (UPBS, 0, NotSerialized)
            {
                PBST [Zero] = ^^PCI0.SBRG.EC0.R820 /* \_SB_.PCI0.SBRG.EC0_.R820 */
                Local5 = ^^PCI0.SBRG.EC0.R830 /* \_SB_.PCI0.SBRG.EC0_.R830 */
                PBST [One] = TATW (POSW (Local5))
                Local5 = ^^PCI0.SBRG.EC0.R850 /* \_SB_.PCI0.SBRG.EC0_.R850 */
                If (!(Local5 & 0x8000))
                {
                    Local5 = TATW (Local5)
                    If ((Local5 != DerefOf (PBST [0x02])))
                    {
                        PBST [0x02] = Local5
                    }
                }

                If (((^^PCI0.SBRG.EC0.RA47 == One) && !^^PCI0.SBRG.EC0.R400))
                {
                    If ((^^PCI0.SBRG.EC0.Q22L == 0x22))
                    {
                        ^^PCI0.SBRG.EC0.Q22C++
                        If ((^^PCI0.SBRG.EC0.Q22C > 0x0F))
                        {
                            ^^PCI0.SBRG.EC0.LLBW = Zero
                        }
                    }

                    PBST [0x02] = FBAS /* \_SB_.BAT0.FBAS */
                }

                PBST [0x03] = ^^PCI0.SBRG.EC0.R870 /* \_SB_.PCI0.SBRG.EC0_.R870 */
                Local0 = ^^PCI0.SBRG.EC0.R820 /* \_SB_.PCI0.SBRG.EC0_.R820 */
                If ((HPBM == One))
                {
                    ^^PCI0.SBRG.EC0.EBHM = One
                    Local0 |= 0x08
                }
                Else
                {
                    ^^PCI0.SBRG.EC0.EBHM = Zero
                    Local0 &= 0xF7
                }

                PBST [Zero] = Local0
            }

            Method (UPBI, 0, NotSerialized)
            {
                Local0 = CBAL /* \CBAL */
                Local1 = LBAL /* \LBAL */
                Local3 = RBAL /* \RBAL */
                Local5 = ^^PCI0.SBRG.EC0.R720 /* \_SB_.PCI0.SBRG.EC0_.R720 */
                If (((Local5 & 0x8000) != 0x8000))
                {
                    Local5 = TATW (Local5)
                    PBIF [One] = Local5
                    PBIF [0x02] = Local5
                    Local2 = (Local5 / 0x64)
                    Local2 += One
                    Local4 = (Local2 * Local1)
                    PBIF [0x05] = (Local4 + 0x02)
                    Local4 = (Local2 * Local0)
                    PBIF [0x06] = (Local4 + 0x02)
                    Local4 = (Local2 * Local3)
                    FBAS = (Local4 + 0x02)
                }

                PBIF [0x04] = ^^PCI0.SBRG.EC0.R740 /* \_SB_.PCI0.SBRG.EC0_.R740 */
                Local6 = ((Local5 * 0x09) / 0x03E8)
                PBIF [0x07] = Local6
                Local6 = ((Local5 * 0x19) / 0x2710)
                PBIF [0x08] = Local6
                PBIF [0x09] = "Primary"
                If (^^PCI0.SBRG.EC0.RA53)
                {
                    PBIF [0x0B] = "NiMH"
                }
                Else
                {
                    PBIF [0x0B] = "LION"
                }

                PBIF [0x0C] = "Hewlett-Packard"
            }

            Method (UPBX, 0, NotSerialized)
            {
                Local0 = CBAL /* \CBAL */
                Local1 = LBAL /* \LBAL */
                Local3 = RBAL /* \RBAL */
                Local5 = ^^PCI0.SBRG.EC0.R720 /* \_SB_.PCI0.SBRG.EC0_.R720 */
                If (((Local5 & 0x8000) == 0x8000))
                {
                    ^^PCI0.SBRG.EC0.SMRD (0x09, 0x16, 0x10, RefOf (Local5))
                }

                If (((Local5 & 0x8000) != 0x8000))
                {
                    Local5 = TATW (Local5)
                    PBIX [0x02] = Local5
                    PBIX [0x03] = Local5
                    PBIX [0x04] = Zero
                    PBIX [0x05] = ^^PCI0.SBRG.EC0.R740 /* \_SB_.PCI0.SBRG.EC0_.R740 */
                    Local2 = (Local5 / 0x64)
                    Local2 += One
                    Local4 = (Local2 * Local1)
                    PBIX [0x06] = (Local4 + 0x02)
                    Local4 = (Local2 * Local0)
                    PBIX [0x07] = (Local4 + 0x02)
                    Local4 = (Local2 * Local3)
                    FBAS = (Local4 + 0x02)
                }

                PBIX [0x08] = ^^PCI0.SBRG.EC0.R320 /* \_SB_.PCI0.SBRG.EC0_.R320 */
                PBIX [0x10] = "Primary"
                PBIX [0x11] = "SerialNumber"
                If (^^PCI0.SBRG.EC0.RA53)
                {
                    PBIX [0x12] = "NiMH"
                }
                Else
                {
                    PBIX [0x12] = "LION"
                }

                PBIX [0x13] = "HP"
            }

            Method (IVBS, 0, NotSerialized)
            {
                PBST [Zero] = Zero
                PBST [One] = Ones
                PBST [0x02] = Ones
                PBST [0x03] = Ones
            }

            Method (IVBI, 0, NotSerialized)
            {
                PBIF [One] = Ones
                PBIF [0x02] = Ones
                PBIF [0x04] = Ones
                PBIF [0x05] = 0x19B4
                PBIF [0x06] = 0x1086
                PBIF [0x07] = 0x01A7
                PBIF [0x08] = 0x75
                PBIF [0x09] = "Bad"
                PBIF [0x0A] = "      "
                PBIF [0x0B] = "Bad"
                PBIF [0x0C] = "Bad"
            }

            Method (IVBX, 0, NotSerialized)
            {
                PBIX [Zero] = Zero
                PBIX [One] = Zero
                PBIX [0x02] = 0xFFFFFFFF
                PBIX [0x03] = 0xFFFFFFFF
                PBIX [0x04] = 0xFFFFFFFF
                PBIX [0x05] = 0xFFFFFFFF
                PBIX [0x06] = 0x0A
                PBIX [0x07] = 0x05
                PBIX [0x08] = Zero
                PBIX [0x09] = "95000"
                PBIX [0x0A] = "25000"
                PBIX [0x0B] = "15000"
                PBIX [0x0C] = "35000"
                PBIX [0x0D] = "25000"
                PBIX [0x0E] = "DSCH_TP"
                PBIX [0x0F] = "CRIT_TP"
                PBIX [0x10] = "CRIT_TP"
                PBIX [0x11] = " "
                PBIX [0x12] = " "
                PBIX [0x13] = " "
            }

            Method (TATW, 1, NotSerialized)
            {
                Local0 = ((^^PCI0.SBRG.EC0.R740 * Arg0) / 0x03E8)
                Return (Local0)
            }
        }
    }

    Scope (\)
    {
        Field (EXBU, AnyAcc, Lock, Preserve)
        {
            Offset (0x800), 
            NUCO,   8, 
            BOD2,   16, 
            SK6U,   8, 
            APWT,   8, 
            RV2Y,   8, 
            SWOL,   8, 
            BSSE,   8, 
            TPSK,   8, 
            TSSK,   8, 
            HPBM,   8, 
            ALCE,   1, 
            Offset (0x80C), 
            DC2E,   32, 
            DC26,   32, 
            DC27,   32, 
            DC28,   32, 
            DC29,   32, 
            DC2A,   32, 
            DC2B,   32, 
            DC2C,   32, 
            DC2D,   32, 
            DC20,   32, 
            DC21,   32, 
            DC22,   32, 
            DC23,   32, 
            DC24,   32, 
            DC25,   32, 
            NVB0,   64, 
            NVDA,   32
        }
    }

    Scope (_SB)
    {
        Device (ACAD)
        {
            Name (_HID, "ACPI0003" /* Power Source Device */)  // _HID: Hardware ID
            Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
            {
                _SB, 
            })
            Name (XX00, Buffer (0x03){})
            Name (ACSB, One)
            Name (ACDC, 0xFF)
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Method (_PSR, 0, NotSerialized)  // _PSR: Power Source
            {
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    Local0 = ^^PCI0.SBRG.EC0.R400 /* \_SB_.PCI0.SBRG.EC0_.R400 */
                }
                Else
                {
                    Local0 = ACSB /* \_SB_.ACAD.ACSB */
                }

                If (!Acquire (^^PCI0.SBRG.EC0.MUT2, 0x012C))
                {
                    If (((Local0 != ACDC) || (ACDC == 0xFF)))
                    {
                        CreateWordField (XX00, Zero, SSZE)
                        CreateByteField (XX00, 0x02, ACST)
                        SSZE = 0x03
                        If (Local0)
                        {
                            AFN4 (One)
                            ACST = Zero
                        }
                        Else
                        {
                            AFN4 (0x02)
                            ACST = One
                        }

                        ALIB (One, XX00)
                        ACDC = Local0
                    }

                    ACSB = Local0
                    Release (^^PCI0.SBRG.EC0.MUT2)
                }

                Return (Local0)
            }
        }
    }

    Scope (_TZ)
    {
        Name (HOTP, 0x69)
        Name (APSD, 0x0C)
        Name (PPSD, Zero)
        Name (TPTM, 0x4B)
        Name (PSVM, Zero)
        Name (HOTF, Zero)
        Name (TMPB, 0xFF)
        ThermalZone (THRM)
        {
            Method (_TMP, 0, NotSerialized)  // _TMP: Temperature
            {
                If (\_SB.PCI0.SBRG.EC0.ECON)
                {
                    Local0 = \_SB.PCI0.SBRG.EC0.R580
                    If (((TMPB != 0xFF) && ((Local0 >= HOTP) && (
                        TMPB < HOTP))))
                    {
                        Local1 = 0x05
                        While ((((Local0 - 0x14) >= TMPB) && (Local1 != 
                            Zero)))
                        {
                            Sleep (0xC8)
                            Local0 = \_SB.PCI0.SBRG.EC0.R580
                            Local1--
                        }
                    }

                    TMPB = Local0
                    If (((HOTF == One) && \_SB.W8OS ()))
                    {
                        Local0 = (HOTP - 0x02)
                    }

                    If (((\_SB.PCI0.SBRG.EC0.R550 == 0x04) && (TMPB == HOTP)))
                    {
                        Local0 = (HOTP - 0x02)
                    }

                    If ((Local0 >= HOTP))
                    {
                        HOTF = One
                    }
                    ElseIf ((Local0 < (HOTP - 0x0A)))
                    {
                        HOTF = Zero
                    }

                    Return ((0x0AAC + (Local0 * 0x0A)))
                }
                Else
                {
                    Return ((0x0AAC + (TPTM * 0x0A)))
                }
            }

            Method (_HOT, 0, Serialized)  // _HOT: Hot Temperature
            {
                If (\_SB.VTOS ())
                {
                    Return ((0x0AAC + (HOTP * 0x0A)))
                }
                Else
                {
                    Return (0x14A2)
                }
            }

            Method (_PSL, 0, NotSerialized)  // _PSL: Passive List
            {
                If (CondRefOf (\_SB.PLTF.C00F))
                {
                    Return (Package (0x10)
                    {
                        \_SB.PLTF.C000, , 
                        \_SB.PLTF.C001, , 
                        \_SB.PLTF.C002, , 
                        \_SB.PLTF.C003, , 
                        \_SB.PLTF.C004, , 
                        \_SB.PLTF.C005, , 
                        \_SB.PLTF.C006, , 
                        \_SB.PLTF.C007, , 
                        \_SB.PLTF.C008, , 
                        \_SB.PLTF.C009, , 
                        \_SB.PLTF.C00A, , 
                        \_SB.PLTF.C00B, , 
                        \_SB.PLTF.C00C, , 
                        \_SB.PLTF.C00D, , 
                        \_SB.PLTF.C00E, , 
                        \_SB.PLTF.C00F, 
                    })
                }
                ElseIf (CondRefOf (\_SB.PLTF.C00D))
                {
                    Return (Package (0x0E)
                    {
                        \_SB.PLTF.C000, , 
                        \_SB.PLTF.C001, , 
                        \_SB.PLTF.C002, , 
                        \_SB.PLTF.C003, , 
                        \_SB.PLTF.C004, , 
                        \_SB.PLTF.C005, , 
                        \_SB.PLTF.C006, , 
                        \_SB.PLTF.C007, , 
                        \_SB.PLTF.C008, , 
                        \_SB.PLTF.C009, , 
                        \_SB.PLTF.C00A, , 
                        \_SB.PLTF.C00B, , 
                        \_SB.PLTF.C00C, , 
                        \_SB.PLTF.C00D, 
                    })
                }
                ElseIf (CondRefOf (\_SB.PLTF.C00B))
                {
                    Return (Package (0x0C)
                    {
                        \_SB.PLTF.C000, , 
                        \_SB.PLTF.C001, , 
                        \_SB.PLTF.C002, , 
                        \_SB.PLTF.C003, , 
                        \_SB.PLTF.C004, , 
                        \_SB.PLTF.C005, , 
                        \_SB.PLTF.C006, , 
                        \_SB.PLTF.C007, , 
                        \_SB.PLTF.C008, , 
                        \_SB.PLTF.C009, , 
                        \_SB.PLTF.C00A, , 
                        \_SB.PLTF.C00B, 
                    })
                }
                ElseIf (CondRefOf (\_SB.PLTF.C009))
                {
                    Return (Package (0x0A)
                    {
                        \_SB.PLTF.C000, , 
                        \_SB.PLTF.C001, , 
                        \_SB.PLTF.C002, , 
                        \_SB.PLTF.C003, , 
                        \_SB.PLTF.C004, , 
                        \_SB.PLTF.C005, , 
                        \_SB.PLTF.C006, , 
                        \_SB.PLTF.C007, , 
                        \_SB.PLTF.C008, , 
                        \_SB.PLTF.C009, 
                    })
                }
                ElseIf (CondRefOf (\_SB.PLTF.C007))
                {
                    Return (Package (0x08)
                    {
                        \_SB.PLTF.C000, , 
                        \_SB.PLTF.C001, , 
                        \_SB.PLTF.C002, , 
                        \_SB.PLTF.C003, , 
                        \_SB.PLTF.C004, , 
                        \_SB.PLTF.C005, , 
                        \_SB.PLTF.C006, , 
                        \_SB.PLTF.C007, 
                    })
                }
                ElseIf (CondRefOf (\_SB.PLTF.C006))
                {
                    Return (Package (0x07)
                    {
                        \_SB.PLTF.C000, , 
                        \_SB.PLTF.C001, , 
                        \_SB.PLTF.C002, , 
                        \_SB.PLTF.C003, , 
                        \_SB.PLTF.C004, , 
                        \_SB.PLTF.C005, , 
                        \_SB.PLTF.C006, 
                    })
                }
                ElseIf (CondRefOf (\_SB.PLTF.C005))
                {
                    Return (Package (0x06)
                    {
                        \_SB.PLTF.C000, , 
                        \_SB.PLTF.C001, , 
                        \_SB.PLTF.C002, , 
                        \_SB.PLTF.C003, , 
                        \_SB.PLTF.C004, , 
                        \_SB.PLTF.C005, 
                    })
                }
                ElseIf (CondRefOf (\_SB.PLTF.C004))
                {
                    Return (Package (0x05)
                    {
                        \_SB.PLTF.C000, , 
                        \_SB.PLTF.C001, , 
                        \_SB.PLTF.C002, , 
                        \_SB.PLTF.C003, , 
                        \_SB.PLTF.C004, 
                    })
                }
                ElseIf (CondRefOf (\_SB.PLTF.C003))
                {
                    Return (Package (0x04)
                    {
                        \_SB.PLTF.C000, , 
                        \_SB.PLTF.C001, , 
                        \_SB.PLTF.C002, , 
                        \_SB.PLTF.C003, 
                    })
                }
                ElseIf (CondRefOf (\_SB.PLTF.C002))
                {
                    Return (Package (0x03)
                    {
                        \_SB.PLTF.C000, , 
                        \_SB.PLTF.C001, , 
                        \_SB.PLTF.C002, 
                    })
                }
                ElseIf (CondRefOf (\_SB.PLTF.C001))
                {
                    Return (Package (0x02)
                    {
                        \_SB.PLTF.C000, , 
                        \_SB.PLTF.C001, 
                    })
                }
                Else
                {
                    Return (Package (0x01)
                    {
                        \_SB.PLTF.C000, 
                    })
                }
            }

            Method (_SCP, 1, Serialized)  // _SCP: Set Cooling Policy
            {
                If (\_SB.W7OS ())
                {
                    If (\_SB.PCI0.SBRG.EC0.ECON)
                    {
                        PSVM = Arg0
                        \_SB.PCI0.SBRG.EC0.TAPM = PSVM /* \_TZ_.PSVM */
                    }
                }
            }

            Method (_TC1, 0, NotSerialized)  // _TC1: Thermal Constant 1
            {
                Return (0x02)
            }

            Method (_TC2, 0, NotSerialized)  // _TC2: Thermal Constant 2
            {
                Return (0x03)
            }

            Method (_TSP, 0, NotSerialized)  // _TSP: Thermal Sampling Period
            {
                Return (0x1E)
            }
        }
    }

    Scope (_SB)
    {
        Device (FAN0)
        {
            Name (_HID, EisaId ("PNP0C0B") /* Fan (Thermal Solution) */)  // _HID: Hardware ID
            Name (_CID, EisaId ("PNP0C0B") /* Fan (Thermal Solution) */)  // _CID: Compatible ID
            Name (_UID, Zero)  // _UID: Unique ID
            Name (_STR, Unicode ("CPU fan"))  // _STR: Description String
            Name (FSLV, Zero)
            Name (LRPM, Zero)
            Name (URPM, 0x1194)
            Name (GRAN, 0x64)
            Name (F1CS, Zero)
            Name (ISV0, Zero)
            Name (ISV1, 0x0834)
            Name (ISV2, 0x0960)
            Name (ISV3, 0x0AF0)
            Name (ISV4, 0x0B54)
            Name (FANL, Zero)
            Name (FANH, Zero)
            Name (TFST, Package (0x03)
            {
                Zero, 
                One, 
                0xFFFFFFFF
            })
            Method (_STA, 0, Serialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Method (_FSL, 1, Serialized)  // _FSL: Fan Set Level
            {
                M460 ("_FSL : Arg0(%x)\n", Arg0, Zero, Zero, Zero, Zero, Zero)
                FSLV = Arg0
            }

            Method (F1LS, 0, NotSerialized)
            {
                M460 ("_Q86 : Fetch fan 1 real speed.(CMOS:0x07 ~ 0x08)\n", Zero, Zero, Zero, Zero, Zero, Zero)
                Local0 = ^^PCI0.SBRG.EC0.FS1L /* \_SB_.PCI0.SBRG.EC0_.FS1L */
                Local1 = ^^PCI0.SBRG.EC0.FS1H /* \_SB_.PCI0.SBRG.EC0_.FS1H */
                FANL = Local0
                FANH = Local1
                F1CS = (Local1 << 0x08)
                F1CS |= Local0
                If ((F1CS == ISV0))
                {
                    FSLV = Zero
                }
                ElseIf (((F1CS > ISV0) && (F1CS <= ISV1)))
                {
                    FSLV = One
                }
                ElseIf (((F1CS > ISV1) && (F1CS <= ISV2)))
                {
                    FSLV = 0x02
                }
                ElseIf (((F1CS > ISV2) && (F1CS <= ISV3)))
                {
                    FSLV = 0x03
                }
                ElseIf ((F1CS > ISV3))
                {
                    FSLV = 0x04
                }

                M460 ("F1LS : FANL(%x) FANH(%x)\n", FANL, FANH, Zero, Zero, Zero, Zero)
            }

            Method (SFNN, 0, NotSerialized)
            {
                M460 ("_Q86 : Send system fan noise notification.\n", Zero, Zero, Zero, Zero, Zero, Zero)
                F1LS ()
                Notify (FAN0, 0x80) // Status Change
            }

            Method (_FST, 0, NotSerialized)  // _FST: Fan Status
            {
                M460 ("_Q86 : _FST\n", Zero, Zero, Zero, Zero, Zero, Zero)
                TFST [One] = FSLV /* \_SB_.FAN0.FSLV */
                TFST [0x02] = F1CS /* \_SB_.FAN0.F1CS */
                Return (TFST) /* \_SB_.FAN0.TFST */
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                M460 ("_Q86 : _DSM (%x)\n", ToInteger (Arg2), Zero, Zero, Zero, Zero, Zero)
                If ((Arg0 == ToUUID ("a7611840-99fe-41ae-a488-35c75926c8eb") /* Fan Trip Points */))
                {
                    Switch (ToInteger (Arg2))
                    {
                        Case (Zero)
                        {
                            Return (Buffer (One)
                            {
                                 0x0F                                             // .
                            })
                        }
                        Case (One)
                        {
                            Return (GRAN) /* \_SB_.FAN0.GRAN */
                        }
                        Case (0x02)
                        {
                            LRPM = DerefOf (Arg3 [Zero])
                            URPM = DerefOf (Arg3 [One])
                            Return (Zero)
                        }
                        Case (0x03)
                        {
                            Return (Package (0x04)
                            {
                                0x0834, 
                                0x0960, 
                                0x0AF0, 
                                0x0B54
                            })
                        }
                        Default
                        {
                            Return (Buffer (One)
                            {
                                 0x00                                             // .
                            })
                        }

                    }
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }
        }
    }

    Scope (_SB)
    {
        Device (LID)
        {
            Name (_HID, EisaId ("PNP0C0D") /* Lid Device */)  // _HID: Hardware ID
            Name (LIDB, One)
            Method (_LID, 0, NotSerialized)  // _LID: Lid Status
            {
                If (^^PCI0.SBRG.EC0.ECON)
                {
                    If (^^PCI0.SBRG.EC0.R520)
                    {
                        Local0 = Zero
                    }
                    Else
                    {
                        Local0 = One
                    }
                }
                Else
                {
                    Local0 = LIDB /* \_SB_.LID_.LIDB */
                }

                LIDB = Local0
                Return (Local0)
            }
        }
    }

    Scope (_SB)
    {
        OperationRegion (PAMI, SystemIO, 0xB2, 0x02)
        Field (PAMI, ByteAcc, NoLock, Preserve)
        {
            SMIE,   8, 
            SMIF,   8
        }

        OperationRegion (ITED, SystemIO, 0x68, One)
        Field (ITED, ByteAcc, NoLock, Preserve)
        {
            DT68,   8
        }

        OperationRegion (ITEC, SystemIO, 0x6C, One)
        Field (ITEC, ByteAcc, NoLock, Preserve)
        {
            CM6C,   8
        }
    }

    Scope (_SB.PCI0.SBRG)
    {
        Device (EC0)
        {
            Name (_HID, EisaId ("PNP0C09") /* Embedded Controller Device */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Name (_GPE, 0x17)  // _GPE: General Purpose Events
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (BFFR, Buffer (0x12)
                {
                    /* 0000 */  0x47, 0x01, 0x62, 0x00, 0x62, 0x00, 0x00, 0x01,  // G.b.b...
                    /* 0008 */  0x47, 0x01, 0x66, 0x00, 0x66, 0x00, 0x00, 0x01,  // G.f.f...
                    /* 0010 */  0x79, 0x00                                       // y.
                })
                Return (BFFR) /* \_SB_.PCI0.SBRG.EC0_._CRS.BFFR */
            }

            Mutex (Z009, 0x00)
            OperationRegion (H2RA, SystemMemory, 0xFE700000, 0x1000)
            Field (H2RA, AnyAcc, NoLock, Preserve)
            {
                Offset (0x1B7), 
                FSUS,   8, 
                Offset (0x300), 
                R000,   8, 
                R010,   8, 
                R020,   8, 
                R030,   8, 
                R040,   256, 
                R240,   8, 
                R250,   8, 
                Offset (0x329), 
                R290,   8, 
                R2A0,   8, 
                R2B0,   8, 
                Offset (0x330), 
                R300,   8, 
                R310,   8, 
                R320,   8, 
                Offset (0x334), 
                R340,   8, 
                R350,   8, 
                Offset (0x337), 
                R370,   8, 
                R380,   8, 
                R390,   8, 
                Offset (0x340), 
                R400,   1, 
                    ,   2, 
                R403,   1, 
                R404,   1, 
                R405,   1, 
                R406,   1, 
                R407,   1, 
                Offset (0x341), 
                R410,   1, 
                    ,   2, 
                R413,   1, 
                R414,   1, 
                Offset (0x342), 
                    ,   4, 
                R424,   1, 
                Offset (0x343), 
                    ,   2, 
                R432,   1, 
                R433,   1, 
                R434,   1, 
                Offset (0x344), 
                Offset (0x344), 
                    ,   2, 
                R442,   1, 
                Offset (0x345), 
                    ,   4, 
                R454,   1, 
                R455,   1, 
                Offset (0x346), 
                Offset (0x347), 
                R470,   8, 
                Offset (0x348), 
                R480,   8, 
                Offset (0x349), 
                R490,   8, 
                Offset (0x34A), 
                R4A0,   8, 
                Offset (0x34B), 
                R4B0,   8, 
                Offset (0x34C), 
                R4C0,   8, 
                Offset (0x34D), 
                    ,   4, 
                    ,   1, 
                    ,   1, 
                R4D6,   1, 
                R4D7,   1, 
                Offset (0x34E), 
                R4E0,   1, 
                Offset (0x34F), 
                R4F0,   8, 
                Offset (0x351), 
                R510,   1, 
                Offset (0x352), 
                R520,   1, 
                Offset (0x353), 
                    ,   1, 
                R531,   1, 
                R532,   1, 
                    ,   1, 
                    ,   1, 
                    ,   1, 
                Offset (0x355), 
                R550,   8, 
                Offset (0x357), 
                R570,   8, 
                Offset (0x358), 
                R580,   8, 
                R590,   8, 
                Offset (0x361), 
                R610,   8, 
                Offset (0x362), 
                R620,   1, 
                Offset (0x366), 
                R660,   1, 
                Offset (0x368), 
                    ,   3, 
                R683,   1, 
                Offset (0x369), 
                Offset (0x369), 
                    ,   4, 
                R694,   1, 
                R695,   1, 
                R696,   1, 
                R697,   1, 
                Offset (0x36A), 
                R6A0,   8, 
                Offset (0x36C), 
                R6C0,   1, 
                R6C1,   1, 
                    ,   5, 
                R6C7,   1, 
                Offset (0x370), 
                R700,   16, 
                R720,   16, 
                R740,   16, 
                R760,   8, 
                Offset (0x378), 
                R780,   16, 
                R7A0,   16, 
                R7C0,   16, 
                R7E0,   16, 
                R800,   16, 
                R820,   8, 
                R830,   16, 
                R850,   16, 
                R870,   16, 
                R890,   8, 
                Offset (0x38D), 
                    ,   5, 
                R8D0,   1, 
                Offset (0x390), 
                R900,   8, 
                Offset (0x391), 
                R910,   8, 
                Offset (0x394), 
                R940,   1, 
                R941,   1, 
                R942,   1, 
                Offset (0x395), 
                Offset (0x395), 
                R950,   8, 
                Offset (0x3A0), 
                RA00,   8, 
                Offset (0x3A2), 
                RA20,   8, 
                RA30,   4, 
                Offset (0x3A4), 
                Offset (0x3A4), 
                RA40,   1, 
                    ,   3, 
                RA44,   1, 
                    ,   1, 
                RA46,   1, 
                RA47,   1, 
                Offset (0x3A5), 
                RA50,   1, 
                    ,   2, 
                RA53,   1, 
                Offset (0x3A6), 
                Offset (0x3A6), 
                RA60,   8, 
                    ,   1, 
                RA71,   1, 
                Offset (0x3A8), 
                    ,   1, 
                RA81,   1, 
                Offset (0x3AA), 
                    ,   1, 
                RAA1,   1, 
                    ,   2, 
                RAA4,   1, 
                Offset (0x3AB), 
                RAB0,   8, 
                Offset (0x3AD), 
                RAD0,   8, 
                Offset (0x3AF), 
                RAF0,   8, 
                Offset (0x3B0), 
                RB00,   8, 
                RB10,   8, 
                Offset (0x3B2), 
                RB20,   8, 
                RB30,   8, 
                Offset (0x3B7), 
                RB70,   8, 
                Offset (0x3B8), 
                RB80,   16, 
                RBA0,   8, 
                RBB0,   8, 
                Offset (0x3C1), 
                RC10,   8, 
                Offset (0x3C5), 
                RC50,   1, 
                RC51,   1, 
                RC52,   1, 
                RC53,   1, 
                RC54,   1, 
                RC55,   1, 
                RC56,   1, 
                RC57,   1, 
                Offset (0x3C6), 
                RC60,   8, 
                RC70,   8, 
                Offset (0x3C9), 
                RC90,   8, 
                Offset (0x3CA), 
                RCA0,   8, 
                Offset (0x3CC), 
                Offset (0x3CD), 
                Offset (0x3CE), 
                Offset (0x3CF), 
                Offset (0x3D0), 
                Offset (0x3D4), 
                RD40,   8, 
                RD50,   8, 
                Offset (0x3D7), 
                RD70,   8, 
                Offset (0x3DA), 
                RDA0,   8, 
                Offset (0x3DB), 
                RDB0,   1, 
                RDB1,   1, 
                    ,   1, 
                RDB3,   1, 
                    ,   1, 
                Offset (0x3DE), 
                RDE0,   8, 
                RDF0,   8, 
                Offset (0x3E0), 
                RE00,   8, 
                RE10,   8, 
                Offset (0x3E2), 
                RE20,   8, 
                Offset (0x3E5), 
                Offset (0x3E6), 
                RE60,   8, 
                Offset (0x3E8), 
                Offset (0x3E9), 
                Offset (0x3EA), 
                Offset (0x3EA), 
                REA0,   8, 
                Offset (0x3EC), 
                Offset (0x3EC), 
                REC0,   1, 
                REC1,   1, 
                REC2,   1, 
                    ,   1, 
                    ,   1, 
                    ,   1, 
                    ,   1, 
                Offset (0x3ED), 
                Offset (0x3EE), 
                Offset (0x3EF), 
                Offset (0x3F0), 
                RF00,   1, 
                Offset (0x3F7), 
                RF70,   8, 
                Offset (0x3F8), 
                RF80,   1, 
                Offset (0x3F9), 
                RF90,   1, 
                Offset (0x447), 
                GBCS,   8, 
                Offset (0x527), 
                FMR1,   8, 
                Offset (0x52F), 
                FMR2,   8, 
                Offset (0x530), 
                FS1H,   8, 
                Offset (0x531), 
                FS1L,   8, 
                Offset (0x532), 
                FS2H,   8, 
                Offset (0x533), 
                FS2L,   8, 
                Offset (0x534), 
                FAS1,   8, 
                FAS2,   8, 
                Offset (0x53F), 
                SFS1,   8, 
                Offset (0x5C0), 
                IFNL,   8, 
                Offset (0x5C1), 
                IFNH,   8, 
                Offset (0x5E9), 
                SFST,   8, 
                Offset (0x8CC), 
                SFS2,   8, 
                Offset (0x8FF), 
                BKBB,   8, 
                Offset (0xA0B), 
                BATT,   8, 
                Offset (0xB00), 
                GBCE,   224, 
                Offset (0xDD0), 
                VER1,   8, 
                VER2,   8, 
                RSV1,   8, 
                RSV2,   8, 
                CCI0,   8, 
                CCI1,   8, 
                CCI2,   8, 
                CCI3,   8, 
                CTL0,   8, 
                CTL1,   8, 
                CTL2,   8, 
                CTL3,   8, 
                CTL4,   8, 
                CTL5,   8, 
                CTL6,   8, 
                CTL7,   8, 
                MGI0,   8, 
                MGI1,   8, 
                MGI2,   8, 
                MGI3,   8, 
                MGI4,   8, 
                MGI5,   8, 
                MGI6,   8, 
                MGI7,   8, 
                MGI8,   8, 
                MGI9,   8, 
                MGIA,   8, 
                MGIB,   8, 
                MGIC,   8, 
                MGID,   8, 
                MGIE,   8, 
                MGIF,   8, 
                MGO0,   8, 
                MGO1,   8, 
                MGO2,   8, 
                MGO3,   8, 
                MGO4,   8, 
                MGO5,   8, 
                MGO6,   8, 
                MGO7,   8, 
                MGO8,   8, 
                MGO9,   8, 
                MGOA,   8, 
                MGOB,   8, 
                MGOC,   8, 
                MGOD,   8, 
                MGOE,   8, 
                MGOF,   8, 
                Offset (0xEE0), 
                    ,   5, 
                LCMC,   1, 
                Offset (0xEE3), 
                LRGB,   96, 
                Offset (0xEF0), 
                BRGB,   96, 
                LBRT,   8
            }

            OperationRegion (ERAM, EmbeddedControl, Zero, 0xFF)
            Field (ERAM, ByteAcc, Lock, Preserve)
            {
                SMPR,   8, 
                SMST,   8, 
                SMAD,   8, 
                SMCM,   8, 
                SMD0,   256, 
                BCNT,   8, 
                SMAA,   8, 
                Offset (0x29), 
                NSPL,   8, 
                NSPT,   8, 
                NFPT,   8, 
                Offset (0x30), 
                BTPL,   8, 
                BTPH,   8, 
                BCLC,   8, 
                Offset (0x34), 
                SRP1,   8, 
                SRP2,   8, 
                Offset (0x37), 
                OSPL,   8, 
                OSPT,   8, 
                OFPT,   8, 
                Offset (0x40), 
                SW2S,   1, 
                    ,   2, 
                ADPP,   1, 
                TAPM,   1, 
                ACRD,   1, 
                    ,   1, 
                PDAC,   1, 
                Offset (0x41), 
                WIN7,   1, 
                    ,   2, 
                WINP,   1, 
                RFLG,   1, 
                Offset (0x42), 
                    ,   4, 
                KBBL,   1, 
                Offset (0x43), 
                    ,   2, 
                ACPS,   1, 
                ACKY,   1, 
                GFXT,   1, 
                Offset (0x44), 
                Offset (0x44), 
                    ,   2, 
                FASO,   1, 
                Offset (0x45), 
                    ,   4, 
                USBC,   1, 
                ETEG,   1, 
                Offset (0x46), 
                Offset (0x47), 
                TNT2,   8, 
                Offset (0x48), 
                TNT3,   8, 
                Offset (0x49), 
                TNT4,   8, 
                Offset (0x4A), 
                IRSN,   8, 
                Offset (0x4B), 
                TNT5,   8, 
                Offset (0x4C), 
                STOE,   8, 
                Offset (0x4D), 
                    ,   4, 
                    ,   1, 
                    ,   1, 
                CSP1,   1, 
                CSP2,   1, 
                Offset (0x4E), 
                LIDE,   1, 
                Offset (0x4F), 
                ACID,   8, 
                Offset (0x51), 
                FAMC,   1, 
                EBHM,   1, 
                Offset (0x52), 
                LIDS,   1, 
                Offset (0x53), 
                    ,   1, 
                    ,   1, 
                PBOA,   1, 
                    ,   1, 
                    ,   1, 
                    ,   1, 
                Offset (0x55), 
                OSLT,   8, 
                Offset (0x57), 
                RTTP,   8, 
                Offset (0x58), 
                RTMP,   8, 
                TRTM,   8, 
                Offset (0x61), 
                SHPM,   8, 
                Offset (0x62), 
                OMCC,   1, 
                Offset (0x66), 
                S3A0,   1, 
                Offset (0x68), 
                    ,   3, 
                PLGS,   1, 
                Offset (0x69), 
                Offset (0x69), 
                    ,   4, 
                BCTC,   1, 
                BMNC,   1, 
                BDSO,   1, 
                BF10,   1, 
                Offset (0x6A), 
                WAKC,   8, 
                Offset (0x6C), 
                ASP1,   1, 
                ASP2,   1, 
                    ,   5, 
                ASBA,   1, 
                Offset (0x70), 
                BADC,   16, 
                BFCC,   16, 
                BADV,   16, 
                BDVO,   8, 
                Offset (0x78), 
                SBRM,   16, 
                SBCV,   16, 
                SCLB,   16, 
                SBFC,   16, 
                SVLB,   16, 
                MBST,   8, 
                MCUR,   16, 
                MBRM,   16, 
                MBCV,   16, 
                NTPE,   8, 
                Offset (0x8D), 
                    ,   5, 
                MBFC,   1, 
                Offset (0x90), 
                NVDO,   8, 
                Offset (0x91), 
                ECDO,   8, 
                Offset (0x94), 
                GSSU,   1, 
                GSMS,   1, 
                CS2S,   1, 
                Offset (0x95), 
                Offset (0x95), 
                HPCM,   8, 
                Offset (0xA0), 
                QBHK,   8, 
                Offset (0xA2), 
                QBBB,   8, 
                Offset (0xA3), 
                ADPI,   4, 
                Offset (0xA4), 
                Offset (0xA4), 
                MBTS,   1, 
                    ,   3, 
                STRE,   1, 
                    ,   1, 
                SHIE,   1, 
                LLBW,   1, 
                Offset (0xA5), 
                MBTC,   1, 
                    ,   2, 
                MBNH,   1, 
                Offset (0xA6), 
                Offset (0xA6), 
                MBDC,   8, 
                    ,   1, 
                CPBT,   1, 
                Offset (0xA8), 
                    ,   1, 
                WDTH,   1, 
                Offset (0xAA), 
                    ,   1, 
                MMBC,   1, 
                    ,   2, 
                SOIE,   1, 
                Offset (0xAB), 
                BICM,   8, 
                Offset (0xAD), 
                SARS,   8, 
                Offset (0xAF), 
                GPUT,   8, 
                Offset (0xB0), 
                RPM1,   8, 
                RPM2,   8, 
                Offset (0xB2), 
                RPM3,   8, 
                RPM4,   8, 
                Offset (0xB7), 
                GTMP,   8, 
                Offset (0xB8), 
                SCUR,   16, 
                OCPC,   8, 
                OCPS,   8, 
                Offset (0xC1), 
                DPPC,   8, 
                Offset (0xC5), 
                SHB1,   1, 
                SHB2,   1, 
                SHB3,   1, 
                SHB4,   1, 
                SHOK,   1, 
                SHFL,   1, 
                SHNP,   1, 
                SHEN,   1, 
                Offset (0xC6), 
                SDVO,   8, 
                SBCW,   8, 
                Offset (0xC9), 
                GTM2,   8, 
                Offset (0xCA), 
                CSFG,   8, 
                Offset (0xCC), 
                Offset (0xCD), 
                Offset (0xCE), 
                Offset (0xCF), 
                Offset (0xD0), 
                Offset (0xD4), 
                PSDH,   8, 
                PSDL,   8, 
                Offset (0xD7), 
                BATF,   8, 
                Offset (0xDA), 
                PSIX,   8, 
                Offset (0xDB), 
                PSKB,   1, 
                PSTP,   1, 
                    ,   1, 
                LANP,   1, 
                    ,   1, 
                Offset (0xDE), 
                ERDE,   8, 
                ERDF,   8, 
                Offset (0xE0), 
                DLTH,   8, 
                DLTL,   8, 
                Offset (0xE2), 
                KBT0,   8, 
                Offset (0xE5), 
                Offset (0xE6), 
                SFHK,   8, 
                Offset (0xE8), 
                Offset (0xE9), 
                Offset (0xEA), 
                Offset (0xEA), 
                ADPH,   8, 
                Offset (0xEC), 
                Offset (0xEC), 
                COLM,   1, 
                FFFF,   1, 
                FFFS,   1, 
                    ,   1, 
                    ,   1, 
                    ,   1, 
                    ,   1, 
                Offset (0xED), 
                Offset (0xEE), 
                Offset (0xEF), 
                Offset (0xF0), 
                DLRP,   1, 
                Offset (0xF7), 
                STTM,   8, 
                Offset (0xF8), 
                NVDS,   1, 
                Offset (0xF9), 
                FTCF,   1
            }

            Name (ECON, Zero)
            Name (Q22L, Zero)
            Name (Q22C, Zero)
            Method (QULV, 0, Serialized)
            {
                ^^^^UBTC.VER0 = VER1 /* \_SB_.PCI0.SBRG.EC0_.VER1 */
                ^^^^UBTC.VER1 = VER2 /* \_SB_.PCI0.SBRG.EC0_.VER2 */
            }

            Method (UWFE, 0, Serialized)
            {
                If ((ECON == One))
                {
                    Acquire (MUT2, 0xFFFF)
                    ^^^^UBTC.MGI0 = MGI0 /* \_SB_.PCI0.SBRG.EC0_.MGI0 */
                    ^^^^UBTC.MGI1 = MGI1 /* \_SB_.PCI0.SBRG.EC0_.MGI1 */
                    ^^^^UBTC.MGI2 = MGI2 /* \_SB_.PCI0.SBRG.EC0_.MGI2 */
                    ^^^^UBTC.MGI3 = MGI3 /* \_SB_.PCI0.SBRG.EC0_.MGI3 */
                    ^^^^UBTC.MGI4 = MGI4 /* \_SB_.PCI0.SBRG.EC0_.MGI4 */
                    ^^^^UBTC.MGI5 = MGI5 /* \_SB_.PCI0.SBRG.EC0_.MGI5 */
                    ^^^^UBTC.MGI6 = MGI6 /* \_SB_.PCI0.SBRG.EC0_.MGI6 */
                    ^^^^UBTC.MGI7 = MGI7 /* \_SB_.PCI0.SBRG.EC0_.MGI7 */
                    ^^^^UBTC.MGI8 = MGI8 /* \_SB_.PCI0.SBRG.EC0_.MGI8 */
                    ^^^^UBTC.MGI9 = MGI9 /* \_SB_.PCI0.SBRG.EC0_.MGI9 */
                    ^^^^UBTC.MGIA = MGIA /* \_SB_.PCI0.SBRG.EC0_.MGIA */
                    ^^^^UBTC.MGIB = MGIB /* \_SB_.PCI0.SBRG.EC0_.MGIB */
                    ^^^^UBTC.MGIC = MGIC /* \_SB_.PCI0.SBRG.EC0_.MGIC */
                    ^^^^UBTC.MGID = MGID /* \_SB_.PCI0.SBRG.EC0_.MGID */
                    ^^^^UBTC.MGIE = MGIE /* \_SB_.PCI0.SBRG.EC0_.MGIE */
                    ^^^^UBTC.MGIF = MGIF /* \_SB_.PCI0.SBRG.EC0_.MGIF */
                    ^^^^UBTC.CCI0 = CCI0 /* \_SB_.PCI0.SBRG.EC0_.CCI0 */
                    ^^^^UBTC.CCI1 = CCI1 /* \_SB_.PCI0.SBRG.EC0_.CCI1 */
                    ^^^^UBTC.CCI2 = CCI2 /* \_SB_.PCI0.SBRG.EC0_.CCI2 */
                    ^^^^UBTC.CCI3 = CCI3 /* \_SB_.PCI0.SBRG.EC0_.CCI3 */
                    CCI0 = Zero
                    CCI3 = Zero
                    CM6C = 0xE1
                    Release (MUT2)
                }
            }

            Method (UWTE, 0, Serialized)
            {
                If ((ECON == One))
                {
                    Acquire (MUT2, 0xFFFF)
                    MGO0 = ^^^^UBTC.MGO0 /* External reference */
                    MGO1 = ^^^^UBTC.MGO1 /* External reference */
                    MGO2 = ^^^^UBTC.MGO2 /* External reference */
                    MGO3 = ^^^^UBTC.MGO3 /* External reference */
                    MGO4 = ^^^^UBTC.MGO4 /* External reference */
                    MGO5 = ^^^^UBTC.MGO5 /* External reference */
                    MGO6 = ^^^^UBTC.MGO6 /* External reference */
                    MGO7 = ^^^^UBTC.MGO7 /* External reference */
                    MGO8 = ^^^^UBTC.MGO8 /* External reference */
                    MGO9 = ^^^^UBTC.MGO9 /* External reference */
                    MGOA = ^^^^UBTC.MGOA /* External reference */
                    MGOB = ^^^^UBTC.MGOB /* External reference */
                    MGOC = ^^^^UBTC.MGOC /* External reference */
                    MGOD = ^^^^UBTC.MGOD /* External reference */
                    MGOE = ^^^^UBTC.MGOE /* External reference */
                    MGOF = ^^^^UBTC.MGOF /* External reference */
                    CTL1 = ^^^^UBTC.CTL1 /* External reference */
                    CTL2 = ^^^^UBTC.CTL2 /* External reference */
                    CTL3 = ^^^^UBTC.CTL3 /* External reference */
                    CTL4 = ^^^^UBTC.CTL4 /* External reference */
                    CTL5 = ^^^^UBTC.CTL5 /* External reference */
                    CTL6 = ^^^^UBTC.CTL6 /* External reference */
                    CTL7 = ^^^^UBTC.CTL7 /* External reference */
                    CTL0 = ^^^^UBTC.CTL0 /* External reference */
                    CM6C = 0xE0
                    Release (MUT2)
                }
            }

            Method (ACPT, 1, Serialized)
            {
            }

            Method (NAPT, 1, Serialized)
            {
            }

            Method (NDPT, 1, Serialized)
            {
            }

            Method (AAPT, 1, Serialized)
            {
            }

            Method (ADPT, 1, Serialized)
            {
            }

            Method (XDPT, 1, Serialized)
            {
            }

            Method (W7RF, 0, NotSerialized)
            {
                If (ECON)
                {
                    If (W7OS ())
                    {
                        If (R414)
                        {
                            RFLG = Zero
                        }

                        If (R413)
                        {
                            WINP = Zero
                        }

                        If (!R410)
                        {
                            WIN7 = One
                        }
                    }
                    ElseIf (ERHO ())
                    {
                        If (R410)
                        {
                            WIN7 = Zero
                        }

                        If (R413)
                        {
                            WINP = Zero
                        }

                        If (!R414)
                        {
                            RFLG = One
                        }
                    }
                    ElseIf (ESUO ())
                    {
                        If (R410)
                        {
                            WIN7 = Zero
                        }

                        If (R414)
                        {
                            RFLG = Zero
                        }

                        If (!R413)
                        {
                            WINP = One
                        }
                    }
                }
            }

            Method (_REG, 2, NotSerialized)  // _REG: Region Availability
            {
                If ((Arg0 == 0x03))
                {
                    ECON = Arg1
                    If ((Arg1 == One))
                    {
                        W7RF ()
                        Notify (\_TZ.THRM, 0x81) // Thermal Trip Point Change
                        SLPF = Zero
                    }
                    Else
                    {
                    }
                }
            }

            Method (_Q09, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Notify (BAT0, 0x80) // Status Change
                Notify (ACAD, 0x80) // Status Change
                If ((^^^^WMID.WMI5 == 0x05))
                {
                    ^^^^WMID.GWEV (0x05, Zero)
                    ^^^^WMID.WMI5 = Zero
                }
            }

            Method (_Q10, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If (VTOS ())
                {
                    If (CondRefOf (\_SB.PCI0.GPP9.PEGP.EDP1))
                    {
                        Notify (^^^GPP9.PEGP.EDP1, 0x87) // Device-Specific
                    }
                    ElseIf (CondRefOf (\_SB.PCI0.GPP9.SWUS.SWDS.VGA.LCD))
                    {
                        Notify (^^^GPP9.SWUS.SWDS.VGA.LCD, 0x87) // Device-Specific
                    }
                    Else
                    {
                        Notify (^^^GPPA.VGA.LCD, 0x87) // Device-Specific
                    }
                }
                Else
                {
                }
            }

            Method (_Q11, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If (VTOS ())
                {
                    If (CondRefOf (\_SB.PCI0.GPP9.PEGP.EDP1))
                    {
                        Notify (^^^GPP9.PEGP.EDP1, 0x86) // Device-Specific
                    }
                    ElseIf (CondRefOf (\_SB.PCI0.GPP9.SWUS.SWDS.VGA.LCD))
                    {
                        Notify (^^^GPP9.SWUS.SWDS.VGA.LCD, 0x86) // Device-Specific
                    }
                    Else
                    {
                        Notify (^^^GPPA.VGA.LCD, 0x86) // Device-Specific
                    }
                }
                Else
                {
                }
            }

            Method (_Q19, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                SMIE = 0xC0
            }

            Method (_Q20, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If (ECON)
                {
                    If (((RA40 && (^^^^BAT0.BATB != 0x1F)) || (!RA40 && (
                        ^^^^BAT0.BATB == 0x1F))))
                    {
                        Notify (BAT0, 0x81) // Information Change
                    }

                    If (((R400 && (^^^^ACAD.ACSB == Zero)) || (!R400 && (
                        ^^^^ACAD.ACSB != Zero))))
                    {
                        Notify (ACAD, 0x80) // Status Change
                        If ((R407 == Zero))
                        {
                            ^^^^WMID.GWEV (0x03, Zero)
                        }
                    }

                    Notify (BAT0, 0x80) // Status Change
                }
            }

            Method (_Q21, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If ((R694 || R695))
                {
                    ^^^^WMID.GWEV (0x16, One)
                }
            }

            Method (_Q22, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Notify (BAT0, 0x80) // Status Change
                Sleep (0x03E8)
                Q22L = 0x22
                Q22C = Zero
                LLBW = Zero
                Notify (BAT0, 0x80) // Status Change
            }

            Method (_Q2A, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Notify (BAT0, 0x81) // Information Change
                Notify (BAT0, 0x80) // Status Change
            }

            Method (_Q33, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
            }

            Method (_Q34, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                WDTH = One
            }

            Method (_Q4D, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                ^^^^WMID.GWEV (0x00020001, Zero)
            }

            Method (_Q60, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If ((0x45 == RA20))
                {
                    ^^^^WMID.GWEV (0x04, Zero)
                }

                If ((0x42 == RA20))
                {
                    ^^^^WMID.GWEV (0x04, Zero)
                }

                If ((0x43 == RA20))
                {
                    ^^^^WMID.GWEV (0x04, Zero)
                }

                If ((0x40 == RA20))
                {
                    ^^^^WMID.GWEV (0x04, Zero)
                }

                If ((0x41 == RA20))
                {
                    ^^^^WMID.GWEV (0x04, Zero)
                }

                If ((0x08 == RA20))
                {
                    ^^^^WMID.GWEV (0x04, Zero)
                }
            }

            Method (_Q61, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If ((0x46 == RA20))
                {
                    ^^^^WMID.GWEV (0x1D, 0x21A7)
                }
            }

            Method (_Q62, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If ((0x44 == RA20))
                {
                    ^^^^WMID.GWEV (0x1D, 0x21A5)
                }
            }

            Method (_Q63, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If ((ECON == One))
                {
                    ^^^^WMID.GWEV (0x0D, BKBB)
                }
            }

            Method (_Q16, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                ^^^^WMID.GWEV (0x04, Zero)
            }

            Method (_Q64, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If ((Zero == RA20))
                {
                    ^^^^WMID.GWEV (0x1D, 0x21A8)
                }
                Else
                {
                    ^^^^WMID.GWEV (0x1D, 0x000121A8)
                }
            }

            Method (_Q65, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                ^^^^WMID.GWEV (0x1B, 0x07)
            }

            Method (_Q6F, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If ((Zero == QBBB))
                {
                    WSMI (One, 0x34, Zero, 0x04, Zero)
                    Switch (WBUF)
                    {
                        Case (Zero)
                        {
                            Local2 = Zero
                        }
                        Case (One)
                        {
                            Local2 = 0x03
                        }
                        Case (0x02)
                        {
                            Local2 = 0x12
                        }

                    }

                    Switch (BKBB)
                    {
                        Case (Zero)
                        {
                            Local1 = 0x21AA
                            Local2 <<= 0x18
                            Local3 = (Local2 | Local1)
                            ^^^^WMID.GWEV (0x1D, Local3)
                        }
                        Case (One)
                        {
                            Local1 = 0x006421AA
                            Local2 <<= 0x18
                            Local3 = (Local2 | Local1)
                            ^^^^WMID.GWEV (0x1D, Local3)
                        }
                        Case (0x02)
                        {
                            Local1 = 0x003221AA
                            Local2 <<= 0x18
                            Local3 = (Local2 | Local1)
                            ^^^^WMID.GWEV (0x1D, Local3)
                        }

                    }
                }
                Else
                {
                    Switch (BKBB)
                    {
                        Case (Zero)
                        {
                            Local2 = Zero
                        }
                        Case (One)
                        {
                            Local2 = 0x64
                        }
                        Case (0x02)
                        {
                            Local2 = 0x32
                        }

                    }

                    WSMI (One, 0x34, Zero, 0x04, Zero)
                    Switch (WBUF)
                    {
                        Case (Zero)
                        {
                            CMSW (0xD3, One)
                            WBUF = One
                            Local1 = 0x030021AA
                            Local2 <<= 0x10
                            Local3 = (Local2 | Local1)
                            ^^^^WMID.GWEV (0x1D, Local3)
                        }
                        Case (One)
                        {
                            CMSW (0xD4, One)
                            WBUF = 0x02
                            Local1 = 0x120021AA
                            Local2 <<= 0x10
                            Local3 = (Local2 | Local1)
                            ^^^^WMID.GWEV (0x1D, Local3)
                        }
                        Case (0x02)
                        {
                            CMSW (0xD5, One)
                            WBUF = Zero
                            Local1 = 0x21AA
                            Local2 <<= 0x10
                            Local3 = (Local2 | Local1)
                            ^^^^WMID.GWEV (0x1D, Local3)
                        }

                    }

                    WSMI (0x02, 0x34, 0x04, Zero, Zero)
                }
            }

            Method (_Q79, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                CMSW (0xEE, 0x79)
                ^^^^NPCF.DBDC = One
                Sleep (0x64)
                Notify (NPCF, 0xC0) // Hardware-Specific
            }

            Method (_Q7A, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                CMSW (0xEE, 0x7A)
                ^^^^NPCF.DBDC = Zero
                Sleep (0x64)
                Notify (NPCF, 0xC0) // Hardware-Specific
            }

            Method (_Q80, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Notify (\_TZ.THRM, 0x80) // Thermal Status Change
            }

            Method (_Q81, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                UWFE ()
                Notify (UBTC, 0x80) // Status Change
            }

            Method (_Q86, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Sleep (0x14)
                ^^^^FAN0.SFNN ()
            }

            Method (_Q9E, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                STTR (Zero)
            }

            Method (_Q8A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                LIDE = Zero
                Notify (LID, 0x80) // Status Change
            }

            Method (_Q8C, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Local0 = RBB0 /* \_SB_.PCI0.SBRG.EC0_.RBB0 */
                OCPC = Local0
            }

            Method (_Q8D, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                CMSW (0x7B, 0x8D)
                If ((NVDE == One))
                {
                    If (CondRefOf (\_SB.PCI0.GPP9.PEGP))
                    {
                        If ((^^^GPP9.GSTA () == One))
                        {
                            Local0 = RDE0 /* \_SB_.PCI0.SBRG.EC0_.RDE0 */
                            Notify (^^^GPP9.PEGP, Local0)
                            ERDF = Local0
                        }
                        Else
                        {
                            ^^^^WMID.TNVD = RDE0 /* \_SB_.PCI0.SBRG.EC0_.RDE0 */
                        }
                    }
                }
            }

            Method (_Q8E, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
            }

            Method (_Q8F, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
            }

            Method (_Q92, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Notify (\_TZ.THRM, 0x81) // Thermal Trip Point Change
            }

            Method (_Q96, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Notify (\_TZ.THRM, 0x81) // Thermal Trip Point Change
            }

            Method (_Q98, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                CMSW (0x7B, 0x98)
                Local0 = (RF70 * 0x03E8)
                DPTC (0x2E, Local0)
            }

            Method (_Q99, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
            }

            Method (_Q9F, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If ((ECON == One))
                {
                    If (((RA40 && (^^^^BAT0.BATB != 0x1F)) || (!RA40 && (
                        ^^^^BAT0.BATB == 0x1F))))
                    {
                        Notify (BAT0, 0x81) // Information Change
                    }

                    Notify (BAT0, 0x80) // Status Change
                    Notify (ACAD, 0x80) // Status Change
                    If ((R407 == Zero))
                    {
                        ^^^^WMID.GWEV (0x03, Zero)
                    }
                }
            }

            Method (_QF2, 0, Serialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If ((ECON == One))
                {
                    Notify (BAT0, 0x81) // Information Change
                }
            }

            Name (ECBF, Buffer (0x20)
            {
                 0x00                                             // .
            })
            Field (H2RA, ByteAcc, Lock, Preserve)
            {
                Offset (0x304), 
                R041,   8
            }

            Field (H2RA, ByteAcc, Lock, Preserve)
            {
                Offset (0x304), 
                R042,   16
            }

            Field (H2RA, ByteAcc, Lock, Preserve)
            {
                Offset (0x304), 
                R043,   64
            }

            Field (H2RA, ByteAcc, Lock, Preserve)
            {
                Offset (0x304), 
                R044,   128
            }

            Field (H2RA, ByteAcc, Lock, Preserve)
            {
                Offset (0x304), 
                R045,   192
            }

            Field (H2RA, ByteAcc, Lock, Preserve)
            {
                Offset (0x304), 
                R046,   256
            }

            Field (ERAM, ByteAcc, Lock, Preserve)
            {
                Offset (0x04), 
                SMB0,   8
            }

            Field (ERAM, ByteAcc, Lock, Preserve)
            {
                Offset (0x04), 
                SMW0,   16
            }

            Field (ERAM, ByteAcc, Lock, Preserve)
            {
                Offset (0x04), 
                FLD0,   64
            }

            Field (ERAM, ByteAcc, Lock, Preserve)
            {
                Offset (0x04), 
                FLD1,   128
            }

            Field (ERAM, ByteAcc, Lock, Preserve)
            {
                Offset (0x04), 
                FLD2,   192
            }

            Field (ERAM, ByteAcc, Lock, Preserve)
            {
                Offset (0x04), 
                FLD3,   256
            }

            Mutex (MUT0, 0x00)
            Mutex (MUT1, 0x00)
            Mutex (MUT2, 0x00)
            Method (SMRD, 4, NotSerialized)
            {
                If (!ECON)
                {
                    Return (0xFF)
                }

                If ((Arg0 != 0x07))
                {
                    If ((Arg0 != 0x09))
                    {
                        If ((Arg0 != 0x0B))
                        {
                            If ((Arg0 != 0x47))
                            {
                                If ((Arg0 != 0xC7))
                                {
                                    Return (0x19)
                                }
                            }
                        }
                    }
                }

                Acquire (MUT1, 0xFFFF)
                Local0 = 0x04
                While ((Local0 > One))
                {
                    SMST = (R010 & 0x40)
                    SMCM = Arg2
                    SMAD = Arg1
                    SMPR = Arg0
                    Local3 = Zero
                    Local4 = Zero
                    While (!Local1 = (R010 & 0xBF))
                    {
                        Sleep (0x02)
                        Local3++
                        If ((Local3 >= 0x32))
                        {
                            SMST = (R010 & 0x40)
                            SMCM = Arg2
                            SMAD = Arg1
                            SMPR = Arg0
                            Local3 = Zero
                            Local4++
                        }

                        If ((Local4 >= 0x04))
                        {
                            Release (MUT1)
                            Return (Local4)
                        }
                    }

                    If ((Local1 == 0x80))
                    {
                        Local0 = Zero
                    }
                    Else
                    {
                        Local0--
                    }
                }

                If (Local0)
                {
                    Local0 = (Local1 & 0x1F)
                }
                Else
                {
                    If ((Arg0 == 0x07))
                    {
                        Arg3 = R041 /* \_SB_.PCI0.SBRG.EC0_.R041 */
                    }

                    If ((Arg0 == 0x47))
                    {
                        Arg3 = R041 /* \_SB_.PCI0.SBRG.EC0_.R041 */
                    }

                    If ((Arg0 == 0xC7))
                    {
                        Arg3 = R041 /* \_SB_.PCI0.SBRG.EC0_.R041 */
                    }

                    If ((Arg0 == 0x09))
                    {
                        Arg3 = R042 /* \_SB_.PCI0.SBRG.EC0_.R042 */
                    }

                    If ((Arg0 == 0x0B))
                    {
                        Local3 = R240 /* \_SB_.PCI0.SBRG.EC0_.R240 */
                        Local2 = 0x20
                        If ((Local3 > Local2))
                        {
                            Local3 = Local2
                        }

                        Local2 = R040 /* \_SB_.PCI0.SBRG.EC0_.R040 */
                        Local3++
                        Local4 = Buffer (Local3){}
                        Local3--
                        Local5 = Zero
                        While ((Local3 > Local5))
                        {
                            GBFE (Local2, Local5, RefOf (Local6))
                            PBFE (Local4, Local5, Local6)
                            Local5++
                        }

                        PBFE (Local4, Local5, Zero)
                        Arg3 = Local4
                    }
                }

                Release (MUT1)
                Return (Local0)
            }

            Method (SMWR, 4, NotSerialized)
            {
                If (!ECON)
                {
                    Return (0xFF)
                }

                If ((Arg0 != 0x06))
                {
                    If ((Arg0 != 0x08))
                    {
                        If ((Arg0 != 0x0A))
                        {
                            If ((Arg0 != 0x46))
                            {
                                If ((Arg0 != 0xC6))
                                {
                                    Return (0x19)
                                }
                            }
                        }
                    }
                }

                Acquire (MUT1, 0xFFFF)
                Local0 = 0x04
                While ((Local0 > One))
                {
                    If ((Arg0 == 0x06))
                    {
                        SMB0 = Arg3
                    }

                    If ((Arg0 == 0x46))
                    {
                        SMB0 = Arg3
                    }

                    If ((Arg0 == 0xC6))
                    {
                        SMB0 = Arg3
                    }

                    If ((Arg0 == 0x08))
                    {
                        SMW0 = Arg3
                    }

                    If ((Arg0 == 0x0A))
                    {
                        SMD0 = Arg3
                    }

                    SMST = (R010 & 0x40)
                    SMCM = Arg2
                    SMAD = Arg1
                    SMPR = Arg0
                    Local3 = Zero
                    While (!Local1 = (R010 & 0xBF))
                    {
                        Sleep (0x02)
                        Local3++
                        If ((Local3 == 0x32))
                        {
                            SMST = (R010 & 0x40)
                            SMCM = Arg2
                            SMAD = Arg1
                            SMPR = Arg0
                            Local3 = Zero
                        }
                    }

                    If ((Local1 == 0x80))
                    {
                        Local0 = Zero
                    }
                    Else
                    {
                        Local0--
                    }
                }

                If (Local0)
                {
                    Local0 = (Local1 & 0x1F)
                }

                Release (MUT1)
                Return (Local0)
            }

            Method (RSPS, 0, NotSerialized)
            {
                PSIX = 0x9E
                Sleep (One)
                Local2 = PSDL /* \_SB_.PCI0.SBRG.EC0_.PSDL */
                If (((Local2 & 0x08) == 0x08))
                {
                    WSMI (One, 0x36, Zero, 0x80, Zero)
                    Local1 = WBUF /* \WBUF */
                    Local4 = ^^^^WMID.SPST (Local1)
                    WSMI (One, 0x37, Zero, 0x80, Zero)
                    Local1 = WBUF /* \WBUF */
                    Local4 = ^^^^WMID.SBCT (Local1)
                    WSMI (One, 0x38, Zero, 0x04, Zero)
                    Local1 = WBUF /* \WBUF */
                    Local4 = ^^^^WMID.SBST (DerefOf (Local1 [Zero]), Zero, Zero, Zero)
                }
            }

            Method (UPHK, 1, Serialized)
            {
                If (!ECON)
                {
                    Return (Zero)
                }

                M460 ("    === ODM.ASL-UPHK(%x) ===\n", Arg0, Zero, Zero, Zero, Zero, Zero)
                Switch (ToInteger (Arg0))
                {
                    Case (0x03)
                    {
                        SMP4 = Zero
                        SOIE = Zero
                        Return (Zero)
                    }
                    Case (0x04)
                    {
                        SMP4 = 0x04
                        SOIE = One
                        M010 (0x9D, One)
                        Notify (LID, 0x80) // Status Change
                        Return (Zero)
                    }
                    Case (0x05)
                    {
                        Acquire (MUT2, 0xFFFF)
                        PSKB = One
                        PSTP = One
                        OSLT = 0x03
                        CSFG = One
                        LANP = One
                        M010 (0x9D, Zero)
                        Release (MUT2)
                        Return (Zero)
                    }
                    Case (0x06)
                    {
                        Acquire (MUT2, 0xFFFF)
                        CSFG = Zero
                        CM6C = 0xE8
                        Sleep (0x05)
                        CM6C = 0x86
                        Sleep (0x05)
                        WAKC = Zero
                        Release (MUT2)
                        Return (Zero)
                    }
                    Case (0x07)
                    {
                        Return (Zero)
                    }
                    Case (0x08)
                    {
                        Return (Zero)
                    }
                    Default
                    {
                        Return (Zero)
                    }

                }
            }
        }
    }

    Scope (_SB.PCI0.SBRG)
    {
        Device (PS2K)
        {
            Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
            {
                Return ("*HPQ8001")
            }

            Name (_CID, EisaId ("PNP0303") /* IBM Enhanced Keyboard (101/102-key, PS/2 Mouse) */)  // _CID: Compatible ID
            Name (_STA, 0x0F)  // _STA: Status
            Name (_CRS, Buffer (0x16)  // _CRS: Current Resource Settings
            {
                /* 0000 */  0x47, 0x01, 0x60, 0x00, 0x60, 0x00, 0x01, 0x01,  // G.`.`...
                /* 0008 */  0x47, 0x01, 0x64, 0x00, 0x64, 0x00, 0x01, 0x01,  // G.d.d...
                /* 0010 */  0x23, 0x02, 0x00, 0x19, 0x79, 0x00               // #...y.
            })
            Name (KBWU, Zero)
            Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
            {
                0x02, 
                0x03
            })
            Method (_PSW, 1, NotSerialized)  // _PSW: Power State Wake
            {
                KBWU = Arg0
            }
        }
    }

    Scope (_SB.PCI0.GPP4)
    {
        Name (_S0W, 0x04)  // _S0W: S0 Device Wake State
        Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
        {
            M460 ("PLA-ASL-\\_SB.PCI0.GPP4._PRW Return GPRW (13, 0x4)\n", Zero, Zero, Zero, Zero, Zero, Zero)
            Return (Package (0x02)
            {
                0x0D, 
                0x04
            })
        }

        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            Local0 = M017 (Zero, 0x02, 0x02, 0x0164, Zero, 0x10)
            M460 ("PLA-ASL-\\_SB.PCI0.GPP4._INI (%x)\n", Local0, Zero, Zero, Zero, Zero, Zero)
            Local0 = 0x60C0
            M018 (Zero, 0x02, 0x02, 0x0164, Zero, 0x10, Local0)
            M460 ("PLA-ASL-\\_SB.PCI0.GPP4._INI (%x)\n", Local0, Zero, Zero, Zero, Zero, Zero)
        }

        PowerResource (PC04, 0x00, 0x0000)
        {
            Name (_STA, One)  // _STA: Status
            Method (_ON, 0, Serialized)  // _ON_: Power On
            {
                Local0 = M017 (Zero, 0x02, 0x02, 0x0164, Zero, 0x10)
                M460 ("PLA-ASL-\\_SB.PCI0.GPP4._ON (%x)\n", Local0, Zero, Zero, Zero, Zero, Zero)
                Local0 = 0x60C0
                M018 (Zero, 0x02, 0x02, 0x0164, Zero, 0x10, Local0)
                M460 ("PLA-ASL-\\_SB.PCI0.GPP4._ON (%x)\n", Local0, Zero, Zero, Zero, Zero, Zero)
            }

            Method (_OFF, 0, Serialized)  // _OFF: Power Off
            {
                Local0 = M017 (Zero, 0x02, 0x02, 0x0164, Zero, 0x10)
                M460 ("PLA-ASL-\\_SB.PCI0.GPP4._OFF (%x)\n", Local0, Zero, Zero, Zero, Zero, Zero)
            }
        }

        Device (XPDV)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Name (_S0W, 0x04)  // _S0W: S0 Device Wake State
            Name (_PR0, Package (0x01)  // _PR0: Power Resources for D0
            {
                PC04, 
            })
            Name (_PR3, Package (0x01)  // _PR3: Power Resources for D3hot
            {
                PC04, 
            })
            OperationRegion (PCFG, PCI_Config, Zero, 0x80)
            Field (PCFG, AnyAcc, NoLock, Preserve)
            {
                DVID,   32, 
                PCMS,   32, 
                Offset (0x45), 
                LPSW,   1
            }

            Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
            {
                If ((PMEE == One))
                {
                    Return (Package (0x02)
                    {
                        0x0D, 
                        0x05
                    })
                }
                Else
                {
                    Return (Package (0x02)
                    {
                        0x0D, 
                        Zero
                    })
                }
            }

            Name (PSWF, Zero)
            Method (_DSW, 3, NotSerialized)  // _DSW: Device Sleep Wake
            {
                If (^^^SBRG.EC0.ECON)
                {
                    ^^^SBRG.EC0.LANP = Arg0
                }

                PSWF = Arg0
            }
        }
    }

    Scope (_SB.PCI0.GPP5)
    {
        Name (_S0W, 0x04)  // _S0W: S0 Device Wake State
        Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
        {
            M460 ("PLA-ASL-\\_SB.PCI0.GPP5._PRW Return GPRW (13, 0x4)\n", Zero, Zero, Zero, Zero, Zero, Zero)
            Return (Package (0x02)
            {
                0x0E, 
                0x04
            })
        }

        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            Local0 = M017 (Zero, 0x02, 0x03, 0x0164, Zero, 0x10)
            M460 ("PLA-ASL-\\_SB.PCI0.GPP5._INI (%x)\n", Local0, Zero, Zero, Zero, Zero, Zero)
            Local0 = 0x60C0
            M018 (Zero, 0x02, 0x03, 0x0164, Zero, 0x10, Local0)
            M460 ("PLA-ASL-\\_SB.PCI0.GPP5._INI (%x)\n", Local0, Zero, Zero, Zero, Zero, Zero)
        }

        PowerResource (PC05, 0x00, 0x0000)
        {
            Name (_STA, One)  // _STA: Status
            Method (_ON, 0, Serialized)  // _ON_: Power On
            {
                Local0 = M017 (Zero, 0x02, 0x03, 0x0164, Zero, 0x10)
                M460 ("PLA-ASL-\\_SB.PCI0.GPP5._ON (%x)\n", Local0, Zero, Zero, Zero, Zero, Zero)
                Local0 = 0x60C0
                M018 (Zero, 0x02, 0x03, 0x0164, Zero, 0x10, Local0)
                M460 ("PLA-ASL-\\_SB.PCI0.GPP5._ON (%x)\n", Local0, Zero, Zero, Zero, Zero, Zero)
            }

            Method (_OFF, 0, Serialized)  // _OFF: Power Off
            {
                Local0 = M017 (Zero, 0x02, 0x03, 0x0164, Zero, 0x10)
                M460 ("PLA-ASL-\\_SB.PCI0.GPP5._OFF (%x)\n", Local0, Zero, Zero, Zero, Zero, Zero)
            }
        }
    }

    Scope (_SB.PCI0.GPP5.WLAN)
    {
        Name (_S0W, 0x04)  // _S0W: S0 Device Wake State
        Name (_PR0, Package (0x01)  // _PR0: Power Resources for D0
        {
            PC05, 
        })
        Name (_PR3, Package (0x01)  // _PR3: Power Resources for D3hot
        {
            PC05, 
        })
        Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
        {
            Sleep (0x01F4)
        }

        Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
        {
        }

        OperationRegion (WCFG, PCI_Config, Zero, 0x90)
        Field (WCFG, AnyAcc, NoLock, Preserve)
        {
            Offset (0x00), 
            WVID,   16, 
            WDID,   16, 
            Offset (0x84), 
            DCAP,   32, 
            DCTR,   16
        }

        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            Return (0x0F)
        }

        Method (_DSW, 3, NotSerialized)  // _DSW: Device Sleep Wake
        {
        }
    }

    Scope (_SB.PCI0.GPP9)
    {
        Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
        {
            M460 ("PLA-ASL-\\_SB.PCI0.GPP9._PRW Return GPRW (0x8, 0x4)\n", Zero, Zero, Zero, Zero, Zero, Zero)
            Return (Package (0x02)
            {
                0x08, 
                0x04
            })
        }
    }

    Method (OPTS, 1, NotSerialized)
    {
        \_SB.S34S (Arg0)
    }

    Method (OWAK, 1, Serialized)
    {
        \_SB.S34W (Arg0)
    }

    Scope (_SB)
    {
        Name (REPM, Zero)
        Name (ORX0, Zero)
        Name (ORX1, Zero)
        Method (S34S, 1, NotSerialized)
        {
            If (^PCI0.SBRG.EC0.ECON)
            {
                ^PCI0.SBRG.EC0.OSLT = Arg0
                ^PCI0.SBRG.EC0.PSKB = ^PCI0.SBRG.PS2K.KBWU /* \_SB_.PCI0.SBRG.PS2K.KBWU */
                ^PCI0.SBRG.EC0.PSTP = One
            }

            If ((Arg0 == 0x03))
            {
                If (^PCI0.SBRG.EC0.ECON)
                {
                    REPM = Zero
                    If ((^PCI0.SBRG.EC0.R400 == Zero))
                    {
                        REPM = One
                        ORX0 = XHP0 /* \_SB_.XHP0 */
                        ORX1 = XHP1 /* \_SB_.XHP1 */
                        XHP0 = 0x1F
                        XHP1 = 0x1F
                    }
                }
            }

            If ((Arg0 == 0x04))
            {
                If ((\_TZ.HOTF == One))
                {
                    \_TZ.HOTF = Zero
                    If ((YRCL < 0x0202))
                    {
                        If (^PCI0.SBRG.EC0.ECON)
                        {
                            Local0 = (\_TZ.HOTP - 0x0A)
                            If ((^PCI0.SBRG.EC0.R580 >= Local0))
                            {
                                HTS4 = One
                            }
                        }
                        Else
                        {
                            HTS4 = One
                        }
                    }
                }

                ^PCI0.SBRG.EC0._Q33 ()
            }
        }

        Method (S34W, 1, NotSerialized)
        {
            If (^PCI0.SBRG.EC0.ECON)
            {
                \_TZ.HOTF = Zero
            }

            If ((Arg0 == 0x03))
            {
                If ((REPM == One))
                {
                    XHP0 = ORX0 /* \_SB_.ORX0 */
                    XHP1 = ORX1 /* \_SB_.ORX1 */
                }
            }

            If (((Arg0 == 0x03) || (Arg0 == 0x04)))
            {
                If ((WBPB || WBUB))
                {
                    Notify (PWRB, 0x02) // Device Wake
                }
                ElseIf (^PCI0.SBRG.EC0.ECON)
                {
                    If (^PCI0.SBRG.EC0.RF90)
                    {
                        Notify (PWRB, 0x02) // Device Wake
                    }
                }

                ^PCI0.SBRG.EC0.W7RF ()
                ^WMID.W05W (0x03)
            }

            ^ACAD.ACDC = 0xFF
        }
    }

    Scope (_SB.I2CD)
    {
        Device (SYNA)
        {
            Name (_CID, "PNP0C50" /* HID Protocol Device (I2C bus) */)  // _CID: Compatible ID
            Name (_UID, One)  // _UID: Unique ID
            Name (_S0W, 0x04)  // _S0W: S0 Device Wake State
            Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
            {
                Return ("SYNA3501")
            }

            Name (HID2, 0x20)
            Name (RBUF, Buffer (0x41)
            {
                /* 0000 */  0x8E, 0x19, 0x00, 0x01, 0x00, 0x01, 0x02, 0x00,  // ........
                /* 0008 */  0x00, 0x01, 0x06, 0x00, 0x80, 0x1A, 0x06, 0x00,  // ........
                /* 0010 */  0x2C, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x49,  // ,.\_SB.I
                /* 0018 */  0x32, 0x43, 0x44, 0x00, 0x8C, 0x20, 0x00, 0x01,  // 2CD.. ..
                /* 0020 */  0x00, 0x01, 0x00, 0x12, 0x00, 0x03, 0x00, 0x00,  // ........
                /* 0028 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
                /* 0030 */  0x00, 0x00, 0x00, 0x05, 0x00, 0x5C, 0x5F, 0x53,  // .....\_S
                /* 0038 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x79,  // B.GPIO.y
                /* 0040 */  0x00                                             // .
            })
            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TPSK == One))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Return (RBUF) /* \_SB_.I2CD.SYNA.RBUF */
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == ToUUID ("3cdff6f7-4267-4555-ad05-b30a3d8938de") /* HID I2C Device */))
                {
                    If ((Arg2 == Zero))
                    {
                        If ((Arg1 == One))
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                        Else
                        {
                            Return (Buffer (One)
                            {
                                 0x00                                             // .
                            })
                        }
                    }
                    ElseIf ((Arg2 == One))
                    {
                        Return (HID2) /* \_SB_.I2CD.SYNA.HID2 */
                    }
                    Else
                    {
                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }
                }
                ElseIf ((Arg0 == ToUUID ("ef87eb82-f951-46da-84ec-14871ac6f84b") /* Unknown UUID */))
                {
                    If ((Arg2 == Zero))
                    {
                        If ((Arg1 == One))
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                    }

                    If ((Arg2 == One))
                    {
                        Return (RBUF) /* \_SB_.I2CD.SYNA.RBUF */
                    }

                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }
        }
    }

    Scope (_SB.I2CD)
    {
        Device (ELAN)
        {
            Name (_CID, "PNP0C50" /* HID Protocol Device (I2C bus) */)  // _CID: Compatible ID
            Name (_UID, One)  // _UID: Unique ID
            Name (_S0W, 0x04)  // _S0W: S0 Device Wake State
            Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
            {
                Return ("ELAN012F")
            }

            Name (HID2, One)
            Name (RBUF, Buffer (0x41)
            {
                /* 0000 */  0x8E, 0x19, 0x00, 0x01, 0x00, 0x01, 0x02, 0x00,  // ........
                /* 0008 */  0x00, 0x01, 0x06, 0x00, 0x80, 0x1A, 0x06, 0x00,  // ........
                /* 0010 */  0x15, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x49,  // ..\_SB.I
                /* 0018 */  0x32, 0x43, 0x44, 0x00, 0x8C, 0x20, 0x00, 0x01,  // 2CD.. ..
                /* 0020 */  0x00, 0x01, 0x00, 0x12, 0x00, 0x03, 0x00, 0x00,  // ........
                /* 0028 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
                /* 0030 */  0x00, 0x00, 0x00, 0x05, 0x00, 0x5C, 0x5F, 0x53,  // .....\_S
                /* 0038 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x79,  // B.GPIO.y
                /* 0040 */  0x00                                             // .
            })
            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TPSK == 0x02))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Return (RBUF) /* \_SB_.I2CD.ELAN.RBUF */
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == ToUUID ("3cdff6f7-4267-4555-ad05-b30a3d8938de") /* HID I2C Device */))
                {
                    If ((Arg2 == Zero))
                    {
                        If ((Arg1 == One))
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                        Else
                        {
                            Return (Buffer (One)
                            {
                                 0x00                                             // .
                            })
                        }
                    }
                    ElseIf ((Arg2 == One))
                    {
                        Return (HID2) /* \_SB_.I2CD.ELAN.HID2 */
                    }
                    Else
                    {
                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }
                }
                ElseIf ((Arg0 == ToUUID ("ef87eb82-f951-46da-84ec-14871ac6f84b") /* Unknown UUID */))
                {
                    If ((Arg2 == Zero))
                    {
                        If ((Arg1 == One))
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                    }

                    If ((Arg2 == One))
                    {
                        Return (RBUF) /* \_SB_.I2CD.ELAN.RBUF */
                    }

                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }
        }
    }

    Method (PTS, 1, NotSerialized)
    {
        If (Arg0)
        {
            HPTS (Arg0)
            CPTS (Arg0)
            OPTS (Arg0)
        }
    }

    Method (WAK, 1, NotSerialized)
    {
        If (Arg0)
        {
            HWAK (Arg0)
            CWAK (Arg0)
            OWAK (Arg0)
            If (((Arg0 == 0x03) || (Arg0 == 0x04)))
            {
                NVDE = Zero
            }
        }
    }

    Scope (_SB.PCI0)
    {
        Name (NBRI, Zero)
        Name (NBAR, Zero)
        Name (NCMD, Zero)
        Name (PXDC, Zero)
        Name (PXLC, Zero)
        Name (PXD2, Zero)
        Name (BRI2, Zero)
        Name (BAR2, Zero)
        Name (CMD2, Zero)
        Name (XDC2, Zero)
        Name (XLC2, Zero)
        Name (XD22, Zero)
        Method (PXCR, 3, Serialized)
        {
            M460 ("PLA-ASL-_SB.PCI0.GPPX.PXCR\n", Zero, Zero, Zero, Zero, Zero, Zero)
            Local0 = Zero
            Local1 = M017 (Arg0, Arg1, Arg2, 0x34, Zero, 0x08)
            While ((Local1 != Zero))
            {
                Local2 = M017 (Arg0, Arg1, Arg2, Local1, Zero, 0x08)
                If (((Local2 == Zero) || (Local2 == 0xFF)))
                {
                    Break
                }

                If ((Local2 == 0x10))
                {
                    Local0 = Local1
                    Break
                }

                Local1 = M017 (Arg0, Arg1, Arg2, (Local1 + One), Zero, 0x08)
            }

            Return (Local0)
        }

        Method (SPCF, 1, Serialized)
        {
            M460 ("PLA-ASL-_SB.PCI0.GPPX.SPCF\n", Zero, Zero, Zero, Zero, Zero, Zero)
            If ((Arg0 == 0x00020001))
            {
                M460 ("PLA-ASL-_SB.PCI0.GPPX.SPCF NVMe 1\n", Zero, Zero, Zero, Zero, Zero, Zero)
                Local0 = M019 (Zero, (Arg0 >> 0x10), (Arg0 & 0xFF), 
                    0x18)
                NBRI = ((Local0 & 0xFF00) >> 0x08)
                NCMD = M019 (NBRI, Zero, Zero, 0x04)
                NBAR = M019 (NBRI, Zero, Zero, 0x10)
                Local1 = PXCR (NBRI, Zero, Zero)
                PXDC = M019 (NBRI, Zero, Zero, (Local1 + 0x08))
                PXLC = M019 (NBRI, Zero, Zero, (Local1 + 0x10))
                PXD2 = M019 (NBRI, Zero, Zero, (Local1 + 0x28))
            }
            Else
            {
                M460 ("PLA-ASL-_SB.PCI0.GPPX.SPCF NVMe 2\n", Zero, Zero, Zero, Zero, Zero, Zero)
                Local0 = M019 (Zero, (Arg0 >> 0x10), (Arg0 & 0xFF), 
                    0x18)
                BRI2 = ((Local0 & 0xFF00) >> 0x08)
                CMD2 = M019 (BRI2, Zero, Zero, 0x04)
                BAR2 = M019 (BRI2, Zero, Zero, 0x10)
                Local1 = PXCR (BRI2, Zero, Zero)
                XDC2 = M019 (BRI2, Zero, Zero, (Local1 + 0x08))
                XLC2 = M019 (BRI2, Zero, Zero, (Local1 + 0x10))
                XD22 = M019 (BRI2, Zero, Zero, (Local1 + 0x28))
            }
        }

        Method (RPCF, 1, Serialized)
        {
            M460 ("PLA-ASL-_SB.PCI0.GPPX.RPCF\n", Zero, Zero, Zero, Zero, Zero, Zero)
            If ((Arg0 == 0x00020001))
            {
                M460 ("PLA-ASL-_SB.PCI0.GPPX.RPCF NVMe 1\n", Zero, Zero, Zero, Zero, Zero, Zero)
                Local1 = PXCR (NBRI, Zero, Zero)
                M020 (NBRI, Zero, Zero, (Local1 + 0x08), PXDC)
                M020 (NBRI, Zero, Zero, (Local1 + 0x10), (PXLC & 0xFFFFFEFC))
                M020 (NBRI, Zero, Zero, (Local1 + 0x28), PXD2)
                M020 (NBRI, Zero, Zero, 0x10, NBAR)
                M020 (NBRI, Zero, Zero, 0x04, 0x06)
            }
            Else
            {
                M460 ("PLA-ASL-_SB.PCI0.GPPX.RPCF NVMe 2\n", Zero, Zero, Zero, Zero, Zero, Zero)
                Local1 = PXCR (BRI2, Zero, Zero)
                M020 (BRI2, Zero, Zero, (Local1 + 0x08), XDC2)
                M020 (BRI2, Zero, Zero, (Local1 + 0x10), (XLC2 & 0xFFFFFEFC))
                M020 (BRI2, Zero, Zero, (Local1 + 0x28), XD22)
                M020 (BRI2, Zero, Zero, 0x10, BAR2)
                M020 (BRI2, Zero, Zero, 0x04, 0x06)
            }
        }

        Method (UPWD, 0, Serialized)
        {
            M460 ("PLA-ASL-_SB.PCI0.UPWD\n", Zero, Zero, Zero, Zero, Zero, Zero)
            OperationRegion (PSMI, SystemIO, 0xB2, 0x02)
            Field (PSMI, ByteAcc, NoLock, Preserve)
            {
                SMIC,   8, 
                SMID,   8
            }

            SMIC = 0xD1
            SMIC = 0xD8
        }
    }

    Scope (_SB)
    {
        Method (MTKS, 1, Serialized)
        {
            Switch (ToInteger (Arg0))
            {
                Case (0x766314C3)
                {
                    Return (One)
                }
                Case (0x796114C3)
                {
                    Return (One)
                }
                Case (0x061614C3)
                {
                    Return (One)
                }
                Default
                {
                    Return (Zero)
                }

            }
        }

        Name (MTVB, 0x8CD3A018)
        Name (MTVL, 0x0500)
        Name (MTBF, Buffer (0x0100){})
        OperationRegion (MTNV, SystemMemory, MTVB, MTVL)
        Field (MTNV, AnyAcc, Lock, Preserve)
        {
            Offset (0x00), 
            DSBF,   2048, 
            Offset (0x100), 
            AGBF,   2048, 
            Offset (0x200), 
            GSBF,   2048, 
            Offset (0x300), 
            CLBF,   2048, 
            Offset (0x400), 
            CCBF,   2048
        }

        Method (MDSB, 0, Serialized)
        {
            MTBF = DSBF /* \_SB_.DSBF */
            Local0 = MTBF /* \_SB_.MTBF */
            Return (Local0)
        }

        Method (MAGB, 0, Serialized)
        {
            MTBF = AGBF /* \_SB_.AGBF */
            Local0 = MTBF /* \_SB_.MTBF */
            Return (Local0)
        }

        Method (MGSB, 0, Serialized)
        {
            MTBF = GSBF /* \_SB_.GSBF */
            Local0 = MTBF /* \_SB_.MTBF */
            Return (Local0)
        }

        Method (MCLB, 0, Serialized)
        {
            MTBF = CLBF /* \_SB_.CLBF */
            Local0 = MTBF /* \_SB_.MTBF */
            Return (Local0)
        }

        Method (MCCB, 0, Serialized)
        {
            MTBF = CCBF /* \_SB_.CCBF */
            Local0 = MTBF /* \_SB_.MTBF */
            Return (Local0)
        }
    }

    Scope (_SB.PCI0.GPP5.WLAN)
    {
        If ((WVID == 0x14C3))
        {
            Method (MTAG, 0, Serialized)
            {
                Name (AGPG, Package (0x17)
                {
                    0x4D, 
                    0x54, 
                    0x41, 
                    0x47, 
                    One, 
                    Zero, 
                    One, 
                    0xC0, 
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero, 
                    0x06, 
                    0x06, 
                    0x06, 
                    0x06, 
                    0x06, 
                    0x06, 
                    0x06, 
                    0x06, 
                    0x04
                })
                Return (AGPG) /* \_SB_.PCI0.GPP5.WLAN.MTAG.AGPG */
            }

            Method (MTCL, 0, Serialized)
            {
                Name (CLPG, Package (0x13)
                {
                    0x4D, 
                    0x54, 
                    0x43, 
                    0x4C, 
                    0x02, 
                    One, 
                    0xFB, 
                    0xCF, 
                    0xE7, 
                    0xD8, 
                    Zero, 
                    Zero, 
                    One, 
                    Zero, 
                    0x80, 
                    Zero, 
                    0x08, 
                    Zero, 
                    Zero
                })
                Return (CLPG) /* \_SB_.PCI0.GPP5.WLAN.MTCL.CLPG */
            }

            Method (MTCC, 0, Serialized)
            {
                Name (CCPG, Package (0x07)
                {
                    0x4D, 
                    0x54, 
                    0x43, 
                    0x43, 
                    Zero, 
                    0x30, 
                    0x30
                })
                Return (CCPG) /* \_SB_.PCI0.GPP5.WLAN.MTCC.CCPG */
            }
        }
    }

    Scope (_SB.PCI0.GPP5.WLAN)
    {
        Method (RTAG, 0, Serialized)
        {
            Name (AG00, Package (0x1F)
            {
                0x52, 
                0x54, 
                0x41, 
                0x47, 
                Zero, 
                0x03, 
                Zero, 
                Zero, 
                Zero, 
                0x0C, 
                0x0B, 
                0x0B, 
                0x0C, 
                0x0C, 
                0x0C, 
                0x0C, 
                0x0C, 
                0x05, 
                0x05, 
                0x06, 
                0x09, 
                0x09, 
                0x09, 
                0x09, 
                0x09, 
                0x08, 
                0x08, 
                0x08, 
                0x08, 
                0x06, 
                0x07
            })
            Return (AG00) /* \_SB_.PCI0.GPP5.WLAN.RTAG.AG00 */
        }

        Name (RTVB, 0xFFFF0000)
        Name (RTVL, 0x0400)
        Name (RTBF, Buffer (0x0100){})
        OperationRegion (RTNV, SystemMemory, RTVB, RTVL)
        Field (RTNV, AnyAcc, Lock, Preserve)
        {
            Offset (0x00), 
            RWRY,   2048, 
            Offset (0x100), 
            RWR1,   2048, 
            Offset (0x200), 
            RWSY,   2048, 
            Offset (0x300), 
            RWGY,   2048
        }

        Method (RWRD, 0, Serialized)
        {
            RTBF = RWRY /* \_SB_.PCI0.GPP5.WLAN.RWRY */
            Local0 = RTBF /* \_SB_.PCI0.GPP5.WLAN.RTBF */
            Return (Local0)
        }

        Method (RWSI, 0, Serialized)
        {
            RTBF = RWSY /* \_SB_.PCI0.GPP5.WLAN.RWSY */
            Local0 = RTBF /* \_SB_.PCI0.GPP5.WLAN.RTBF */
            Return (Local0)
        }

        Method (RWGS, 0, Serialized)
        {
            RTBF = RWGY /* \_SB_.PCI0.GPP5.WLAN.RWGY */
            Local0 = RTBF /* \_SB_.PCI0.GPP5.WLAN.RTBF */
            Return (Local0)
        }

        Method (RWSC, 4, Serialized)
        {
            If ((Arg1 != Zero))
            {
                Return (Zero)
            }

            Switch (ToInteger (Arg2))
            {
                Case (Zero)
                {
                    Return (Buffer (0x04)
                    {
                         0x7F, 0x00, 0x00, 0x00                           // ....
                    })
                }
                Case (One)
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
                Case (0x02)
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
                Case (0x03)
                {
                    Return (Buffer (One)
                    {
                         0x01                                             // .
                    })
                }
                Case (0x04)
                {
                    Return (Buffer (0x12)
                    {
                        /* 0000 */  0x00, 0xE0, 0x4C, 0x00, 0x01, 0x06, 0x54, 0x57,  // ..L...TW
                        /* 0008 */  0x4A, 0x50, 0x45, 0x55, 0x58, 0x58, 0x41, 0x54,  // JPEUXXAT
                        /* 0010 */  0x54, 0x45                                       // TE
                    })
                }
                Case (0x05)
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
                Case (0x06)
                {
                    Return (Buffer (One)
                    {
                         0x03                                             // .
                    })
                }

            }

            Return (Zero)
        }

        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            If ((Arg0 == ToUUID ("d2a8c3e8-4b69-4f00-82bd-fe8607803aa7") /* Unknown UUID */))
            {
                Return (RWSC (Arg0, Arg1, Arg2, Arg3))
            }

            Return (Zero)
        }
    }
}

