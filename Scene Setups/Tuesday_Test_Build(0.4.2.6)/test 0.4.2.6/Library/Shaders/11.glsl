
   #~T╠╤ЦКЭсCPБUq                	                                          d      ░&                                                                            %   	   5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ░&          ┐uЕУ69╢Н┐uЕУ69╢Н+┘збЫn╙                                                                                                                                                          ^Л                                                                                                                                                       	             QЛ                                                                                                                                                                  \Л                                                                                                                                                                   \Л                                                                                                                                                                  \Л                                              %                                                                                                                                                                                                                                                                                                                                                           text textColor u_Model u_Proj u_View 
                      QЛ                                         PЛ                     a_Position a_TexCoords                      PЛ                                               RЛ                                  v_TexCoords gl_Position                                               color 
                      QЛ                                       PЛ                   a_Position a_TexCoords                       PЛ                   v_TexCoords                       RЛ                    color  ╜  !!NVvp5.0
OPTION NV_internal;
OPTION NV_bindless_texture;
PARAM c[12] = { program.local[0..11] };
ATTRIB vertex_attrib[] = { vertex.attrib[0..1] };
OUTPUT result_attrib[] = { result.attrib[0..0] };
TEMP R0, R1, R2, R3;
TEMP T;
MUL.F R0, c[9], c[4].y;
MAD.F R0, c[8], c[4].x, R0;
MAD.F R1, c[10], c[4].z, R0;
MUL.F R0, c[9], c[5].y;
MUL.F R2, vertex.attrib[0].y, c[1];
MAD.F R0, c[8], c[5].x, R0;
MAD.F R2, vertex.attrib[0].x, c[0], R2;
MAD.F R2, vertex.attrib[0].z, c[2], R2;
MAD.F R0, c[10], c[5].z, R0;
ADD.F R3, R2, c[3];
MAD.F R0, c[11], c[5].w, R0;
MUL.F R0, R3.y, R0;
MAD.F R1, c[11], c[4].w, R1;
MAD.F R2, R3.x, R1, R0;
MUL.F R0, c[9], c[6].y;
MUL.F R1, c[7].y, c[9];
MAD.F R0, c[8], c[6].x, R0;
MAD.F R1, c[7].x, c[8], R1;
MAD.F R0, c[10], c[6].z, R0;
MAD.F R1, c[7].z, c[10], R1;
MAD.F R0, c[11], c[6].w, R0;
MAD.F R0, R3.z, R0, R2;
MAD.F R1, c[7].w, c[11], R1;
MAD.F result.position, R3.w, R1, R0;
MOV.F result.attrib[0].xy, vertex.attrib[1];
END
                                                                                                                                                                                                                                                                                                                                                                                                                                                               │  !!NVfp5.0
OPTION NV_internal;
OPTION NV_gpu_program_fp64;
OPTION NV_bindless_texture;
PARAM c[2] = { program.local[0..1] };
ATTRIB fragment_attrib[] = { fragment.attrib[0..0] };
TEMP R0, R1;
LONG TEMP D0;
TEMP T;
OUTPUT result_color0 = result.color;
PK64.U D0.x, c[0];
MOV.F R1.xyz, c[1];
TEX.F R0.x, fragment.attrib[0], handle(D0.x), 2D;
MOV.F R0.yzw, {1, 0, 0, 0}.x;
MOV.F R1.w, {1, 0, 0, 0}.x;
MUL.F result_color0, R1, R0.yzwx;
END
                                                                                                                                                                                                                                                                                                                                                        