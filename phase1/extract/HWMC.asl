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
