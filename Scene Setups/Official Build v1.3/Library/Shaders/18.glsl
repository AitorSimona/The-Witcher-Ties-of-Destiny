
   �m�A�r��m�FS|�                	                                    `   �  f)                                                                                                                                        B      7                                                                                           ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����                                                                                                ��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������                         
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    f)              �u��69���u��69���0��)��!                                                                                                                                         
                                                                                     ^�                         ����    ������������                                      �   ����    ������������������������                                                     R�                          ����    ������������                                     �   ����   ������������������������                                                                              ����    ������������                                     �   ����   ������������������������                                          ,          \�                          ����    ������������                                     �      ����������������������������                                          4          \�                          ����    ������������                                     �       ����������������������������                                          ;          \�                          ����    ������������'                                     �      ����������������������������                                                                                       �?  �?  �?  �?                                                                                                                                                                                                    u_AlbedoTexture u_Color u_HasDiffuseTexture u_Model u_Proj u_View 
                      Q�                     
                    P�                     a_Position a_TexCoord                      P�                          ��������             R�                          ��������v_texCoords gl_Position 
                  ����Q�                   
                ����P�                   a_Position a_TexCoord                   ����P�                   v_texCoords  �  !!NVvp5.0
OPTION NV_internal;
OPTION NV_bindless_texture;
PARAM c[12] = { program.local[0..11] };
ATTRIB vertex_attrib[] = { vertex.attrib[0..3] };
OUTPUT result_attrib[] = { result.attrib[0..0] };
TEMP R0, R1, R2, R3;
TEMP T;
MUL.F32 R0, c[1], c[4].y;
MAD.F32 R0, c[0], c[4].x, R0;
MAD.F32 R1, c[2], c[4].z, R0;
MUL.F32 R0, c[1], c[5].y;
MUL.F32 R2, vertex.attrib[0].y, c[9];
MAD.F32 R0, c[0], c[5].x, R0;
MAD.F32 R2, vertex.attrib[0].x, c[8], R2;
MAD.F32 R2, vertex.attrib[0].z, c[10], R2;
MAD.F32 R0, c[2], c[5].z, R0;
ADD.F32 R3, R2, c[11];
MAD.F32 R0, c[3], c[5].w, R0;
MUL.F32 R0, R3.y, R0;
MAD.F32 R1, c[3], c[4].w, R1;
MAD.F32 R2, R3.x, R1, R0;
MUL.F32 R0, c[1], c[6].y;
MUL.F32 R1, c[7].y, c[1];
MAD.F32 R0, c[0], c[6].x, R0;
MAD.F32 R1, c[7].x, c[0], R1;
MAD.F32 R0, c[2], c[6].z, R0;
MAD.F32 R1, c[7].z, c[2], R1;
MAD.F32 R0, c[3], c[6].w, R0;
MAD.F32 R0, R3.z, R0, R2;
MAD.F32 R1, c[7].w, c[3], R1;
MAD.F32 result.position, R3.w, R1, R0;
MOV.F result.attrib[0].xy, vertex.attrib[3];
END
                                                                                                                                                                                                                                                                               ��������������������������������                                                                                                                                        ��������$  !!NVfp5.0
OPTION NV_internal;
OPTION NV_gpu_program_fp64;
OPTION NV_bindless_texture;
PARAM c[3] = { program.local[0..2] };
ATTRIB fragment_attrib[] = { fragment.attrib[0..0] };
TEMP R0;
LONG TEMP D0;
TEMP T;
TEMP RC;
SHORT TEMP HC;
SEQ.S R0.x, c[1], {1, 0, 0, 0};
MOV.U.CC RC.x, -R0;
IF NE.x;
PK64.U D0.x, c[0];
TEX.F R0.w, fragment.attrib[0], handle(D0.x), 2D;
MUL.F32 R0.x, R0.w, c[2].w;
ELSE;
MOV.F R0.x, c[2].w;
ENDIF;
SLT.F32 R0.x, R0, {0.00999999978, 0, 0, 0};
TRUNC.U.CC HC.x, R0;
IF NE.x;
MOV.U.CC RC.x, {1, 0, 0, 0};
KIL NE.x;
ENDIF;
END
                                     �?  �?  �?  �?                                                                                               �������������������������������                                                                                                                                       ��������                        