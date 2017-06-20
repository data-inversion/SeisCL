/*------------------------------------------------------------------------
 * Copyright (C) 2016 For the list of authors, see file AUTHORS.
 *
 * This file is part of SeisCL.
 *
 * SeisCL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.0 of the License only.
 *
 * SeisCL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SeisCL. See file COPYING and/or
 * <http://www.gnu.org/licenses/gpl-3.0.html>.
 --------------------------------------------------------------------------*/

/*Adjoint sources */

/*Define useful macros to be able to write a matrix formulation in 2D with OpenCl */
#if ND==3
#define vx(z,y,x)   vx[(x)*NY*(NZ+NZ_al16)+(y)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vy(z,y,x)   vy[(x)*NY*(NZ+NZ_al16)+(y)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vz(z,y,x)   vz[(x)*NY*(NZ+NZ_al16)+(y)*(NZ+NZ_al16)+(z)+NZ_al0]

#define vx_buf1(z,y,x)   vx_buf1[(x)*NY*(NZ+NZ_al16)+(y)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vy_buf1(z,y,x)   vy_buf1[(x)*NY*(NZ+NZ_al16)+(y)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vz_buf1(z,y,x)   vz_buf1[(x)*NY*(NZ+NZ_al16)+(y)*(NZ+NZ_al16)+(z)+NZ_al0]

#define vx_buf2(z,y,x)   vx_buf2[(x)*NY*(NZ+NZ_al16)+(y)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vy_buf2(z,y,x)   vy_buf2[(x)*NY*(NZ+NZ_al16)+(y)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vz_buf2(z,y,x)   vz_buf2[(x)*NY*(NZ+NZ_al16)+(y)*(NZ+NZ_al16)+(z)+NZ_al0]
#endif

#if ND==2 || ND==21
#define vx(z,y,x)  vx[(x)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vy(z,y,x)  vy[(x)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vz(z,y,x)  vz[(x)*(NZ+NZ_al16)+(z)+NZ_al0]

#define vx_buf1(z,y,x)  vx_buf1[(x)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vy_buf1(z,y,x)  vy_buf1[(x)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vz_buf1(z,y,x)  vz_buf1[(x)*(NZ+NZ_al16)+(z)+NZ_al0]

#define vx_buf2(z,y,x)  vx_buf2[(x)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vy_buf2(z,y,x)  vy_buf2[(x)*(NZ+NZ_al16)+(z)+NZ_al0]
#define vz_buf2(z,y,x)  vz_buf2[(x)*(NZ+NZ_al16)+(z)+NZ_al0]

#endif

__kernel void fill_transfer_buff_v_out( __global float *vx, __global float *vy, __global float *vz,
                                       __global float *vx_buf1,  __global float *vy_buf1, __global float *vz_buf1,
                                       __global float *vx_buf2,  __global float *vy_buf2, __global float *vz_buf2)
{
#if ND==3
    // If we use local memory
#if local_off==0
    
    int gidz = get_global_id(0)+fdoh;
    int gidy = get_global_id(1)+fdoh;
    int gidx = get_global_id(2);
    
    // If local memory is turned off
#elif local_off==1
    
    int gid = get_global_id(0);
    int gidz = gid%glsizez+fdoh;
    int gidy = (gid/glsizez)%glsizey+fdoh;
    int gidx = gid/(glsizez*glsizey);
    
#endif
    
#else
    
    // If we use local memory
#if local_off==0
    int gidz = get_global_id(0)+fdoh;
    int gidx = get_global_id(1);
    int gidy = 0;
    
    // If local memory is turned off
#elif local_off==1
    int gid = get_global_id(0);
    int gidz = gid%glsizez+fdoh;
    int gidx = (gid/glsizez);
    int gidy = 0;
#endif
#endif

#if !(dev==0 & MYLOCALID==0)
    vx_buf1(gidz,gidy,gidx)=vx(gidz,gidy,gidx+fdoh);
    vz_buf1(gidz,gidy,gidx)=vz(gidz,gidy,gidx+fdoh);
#endif
#if !(dev==num_devices-1 & MYLOCALID==NLOCALP-1)
    if (vx(gidz,gidy,gidx+NX-fdoh)>0){
        printf( "%f\n",vx(gidz,gidy,gidx+NX-fdoh));
               }
    printf( "%f\n",vx[gidz]);
    vx_buf2(gidz,gidy,gidx+fdoh)=vx(gidz,gidy,gidx+NX-fdoh);
    vz_buf2(gidz,gidy,gidx+fdoh)=vz(gidz,gidy,gidx+NX-fdoh);
#endif
    
    
#if ND==3
#if !(dev==0 & MYLOCALID==0)
    vy_buf1(gidz,gidy,gidx)=vy(gidz,gidy,gidx+fdoh);
#endif
#if !(dev==num_devices-1 & MYLOCALID==NLOCALP-1)
    vy_buf2(gidz,gidy,gidx+fdoh)=vy(gidz,gidy,gidx+NX-fdoh);
#endif
#endif


}

__kernel void fill_transfer_buff_v_in( __global float *vx, __global float *vy, __global float *vz,
                                       __global float *vx_buf1,  __global float *vy_buf1, __global float *vz_buf1,
                                       __global float *vx_buf2,  __global float *vy_buf2, __global float *vz_buf2)
{
#if ND==3
    // If we use local memory
#if local_off==0
    
    int gidz = get_global_id(0)+fdoh;
    int gidy = get_global_id(1)+fdoh;
    int gidx = get_global_id(2);
    
    // If local memory is turned off
#elif local_off==1
    
    int gid = get_global_id(0);
    int gidz = gid%glsizez+fdoh;
    int gidy = (gid/glsizez)%glsizey+fdoh;
    int gidx = gid/(glsizez*glsizey);
    
#endif
    
#else
    
    // If we use local memory
#if local_off==0
    int gidz = get_global_id(0)+fdoh;
    int gidx = get_global_id(1);
    int gidy = 0;
    
    // If local memory is turned off
#elif local_off==1
    int gid = get_global_id(0);
    int gidz = gid%glsizez+fdoh;
    int gidx = (gid/glsizez);
    int gidy = 0;
#endif
#endif
    
#if !(dev==0 & MYLOCALID==0)
    vx(gidz,gidy,gidx+fdoh)=vx_buf1(gidz,gidy,gidx);
    vz(gidz,gidy,gidx+fdoh)=vz_buf1(gidz,gidy,gidx);
#endif
#if !(dev==num_devices-1 & MYLOCALID==NLOCALP-1)
    vx(gidz,gidy,gidx+NX-fdoh)=vx_buf2(gidz,gidy,gidx+fdoh);
    vz(gidz,gidy,gidx+NX-fdoh)=vz_buf2(gidz,gidy,gidx+fdoh);
#endif
    
    
#if ND==3
#if !(dev==0 & MYLOCALID==0)
    vy(gidz,gidy,gidx+fdoh)=vy_buf1(gidz,gidy,gidx);
#endif
#if !(dev==num_devices-1 & MYLOCALID==NLOCALP-1)
    vy(gidz,gidy,gidx+NX-fdoh)=vy_buf2(gidz,gidy,gidx+fdoh);
#endif
#endif
    
}

