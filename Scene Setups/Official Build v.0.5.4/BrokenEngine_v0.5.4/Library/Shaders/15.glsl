
   7╚F╖SхУ╨*P@├айзk                	                                       `      G#                                                                            '      #                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      G#          ┐uЕУ69╢Н┐uЕУ69╢НМх3QVГ                                                                                         
                 
   	                                             `Л                                                                                                                                                                                                                                                                                                                                      \Л                                                                                                                                                                   \Л                                                                                                                                                                                          А?                                                                                                                                skybox u_GammaCorrection u_Proj u_View 
                      QЛ                     a_Position        	              QЛ                                     
          RЛ                                  TexCoords gl_Position                                               color 
                      QЛ                   a_Position 	                      QЛ                   TexCoords                       RЛ                    color    !!NVvp5.0
OPTION NV_internal;
OPTION NV_bindless_texture;
PARAM c[8] = { program.local[0..7] };
ATTRIB vertex_attrib[] = { vertex.attrib[0..0] };
OUTPUT result_attrib[] = { result.attrib[0..0] };
TEMP R0, R1;
TEMP T;
MUL.F R0, vertex.attrib[0].y, c[1];
MAD.F R0, vertex.attrib[0].x, c[0], R0;
MAD.F R0, vertex.attrib[0].z, c[2], R0;
ADD.F R0, R0, c[3];
MUL.F R1, R0.y, c[5];
MAD.F R1, R0.x, c[4], R1;
MAD.F R1, R0.z, c[6], R1;
MAD.F result.position, R0.w, c[7], R1;
MUL.F result.attrib[0].xyz, vertex.attrib[0], {1, -1, 0, 0}.xyxw;
END
                                                                                                                                                                                                                                                                                                                               э  !!NVfp5.0
OPTION NV_internal;
OPTION NV_gpu_program_fp64;
OPTION NV_bindless_texture;
PARAM c[2] = { program.local[0..1] };
ATTRIB fragment_attrib[] = { fragment.attrib[0..0] };
TEMP R0, R1;
LONG TEMP D0;
TEMP T;
OUTPUT result_color0 = result.color;
PK64.U D0.x, c[1];
TEX.F R0, fragment.attrib[0], handle(D0.x), CUBE;
RCP.F R1.x, c[0].x;
POW.F result_color0.x, R0.x, R1.x;
POW.F result_color0.y, R0.y, R1.x;
POW.F result_color0.z, R0.z, R1.x;
POW.F result_color0.w, R0.w, {1, 0, 0, 0}.x;
END
     А?                                                                                                                                                                                                                                                                                                                                                