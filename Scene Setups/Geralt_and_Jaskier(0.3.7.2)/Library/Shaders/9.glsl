
   hЅЂЗќЊў╗▒Ђ▓Є                	                                        d      T$                                                                            #      3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         T$          ┐uЁЊ69ХЇ┐uЁЊ69ХЇЏжд"kЮЗ                                                                                      	                    	                                                QІ                                                                                                                                                                    \І                                                                                                                                                      
             \І                                                                                                                                                                  \І                                              #                                                                                                                                                                                                                                                                                                                                             Color model_matrix projection view                       QІ                     position                      QІ                                     	          RІ                                  ourColor gl_Position                                               color                       QІ                   position                       QІ                   ourColor                       RІ                    color  с  !!NVvp5.0
OPTION NV_internal;
OPTION NV_bindless_texture;
PARAM c[13] = { program.local[0..12] };
ATTRIB vertex_attrib[] = { vertex.attrib[0..0] };
OUTPUT result_attrib[] = { result.attrib[0..0] };
TEMP R0, R1, R2, R3;
TEMP T;
MUL.F32 R0, c[9], c[4].y;
MAD.F32 R0, c[8], c[4].x, R0;
MAD.F32 R1, c[10], c[4].z, R0;
MUL.F32 R0, c[9], c[5].y;
MUL.F32 R2, vertex.attrib[0].y, c[1];
MAD.F32 R0, c[8], c[5].x, R0;
MAD.F32 R2, vertex.attrib[0].x, c[0], R2;
MAD.F32 R2, vertex.attrib[0].z, c[2], R2;
MAD.F32 R0, c[10], c[5].z, R0;
ADD.F32 R3, R2, c[3];
MAD.F32 R0, c[11], c[5].w, R0;
MUL.F32 R0, R3.y, R0;
MAD.F32 R1, c[11], c[4].w, R1;
MAD.F32 R2, R3.x, R1, R0;
MUL.F32 R0, c[9], c[6].y;
MUL.F32 R1, c[7].y, c[9];
MAD.F32 R0, c[8], c[6].x, R0;
MAD.F32 R1, c[7].x, c[8], R1;
MAD.F32 R0, c[10], c[6].z, R0;
MAD.F32 R1, c[7].z, c[10], R1;
MAD.F32 R0, c[11], c[6].w, R0;
MAD.F32 R0, R3.z, R0, R2;
MAD.F32 R1, c[7].w, c[11], R1;
MAD.F32 result.position, R3.w, R1, R0;
MOV.F result.attrib[0].xyz, c[12];
END
                                                                                                                                                                                                                                                                                                                                                                                                                                                               ш   !!NVfp5.0
OPTION NV_internal;
OPTION NV_bindless_texture;
ATTRIB fragment_attrib[] = { fragment.attrib[0..0] };
TEMP T;
OUTPUT result_color0 = result.color;
MOV.F result_color0.xyz, fragment.attrib[0];
MOV.F result_color0.w, {1, 0, 0, 0}.x;
END
                                                                                                                                                                                                                            