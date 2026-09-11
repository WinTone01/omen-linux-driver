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
