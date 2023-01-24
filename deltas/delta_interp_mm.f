C NCLFORTSTART

        subroutine delta(interp_ta,interp_tas,
     +  interp_hur,interp_hurs,interp_tos,interp_ts,
     +  interp_TT3h,interp_RH3h,interp_SST3h,interp_SKINTEMP3h,
     +  nlat,nlon,nlev,ntim,nlevel,ntime3h)

        INTEGER xx,yy,zz,tt,nt
        INTEGER nlat,nlon,nlev,nlevel
        INTEGER ntim,ntime3h
        REAL r
        REAL interp_ta(nlon,nlat,nlev,ntim)
        REAL interp_hur(nlon,nlat,nlev,ntim)
        REAL interp_hurs(nlon,nlat,ntim)
        REAL interp_tos(nlon,nlat,ntim)
        REAL interp_ts(nlon,nlat,ntim)
        REAL interp_tas(nlon,nlat,ntim)
        REAL interp_TT3h(nlon,nlat,nlevel,ntime3h)
        REAL interp_RH3h(nlon,nlat,nlevel,ntime3h)
        REAL interp_SST3h(nlon,nlat,ntime3h)
        REAL interp_SKINTEMP3h(nlon,nlat,ntime3h)
C NCLEND

CLooping through mid of two months at a time, to calculate 3hourly steps between them
        nt =1
        do tt = 1,ntime3h

CFraction of difference between the two deltas to be added to the first delta at each step r = (t-t0)/(t1-t0)

        r  = (1.0*(tt-1))/(ntime3h-1)

        print *,nt,1, tt, ntime3h,r
        do xx = 1,nlon
        do yy = 1,nlat

        do zz = 1,nlevel
        if(zz.eq.1) then

        if(interp_tas(xx,yy,nt).ne.1e+20) then

        interp_TT3h(xx,yy,zz,tt) = interp_tas(xx,yy,nt) +
     +    r*(interp_tas(xx,yy,nt+1)-interp_tas(xx,yy,nt))

        end if

        else

        if(interp_ta(xx,yy,zz-1,nt).ne.1e+20) then

        interp_TT3h(xx,yy,zz,tt) = interp_ta(xx,yy,zz-1,nt) +
     +    r*(interp_ta(xx,yy,zz-1,nt+1) - interp_ta(xx,yy,zz-1,nt))

        end if

        end if

        if(zz.eq.1) then

        if(interp_hurs(xx,yy,nt).ne.1e+20) then

        interp_RH3h(xx,yy,zz,tt) = interp_hurs(xx,yy,nt) +
     +     r*(interp_hurs(xx,yy,nt+1)-interp_hurs(xx,yy,nt))
 
        end if

        else

        if(interp_hur(xx,yy,zz-1,nt).ne.1e+20) then

        interp_RH3h(xx,yy,zz,tt) = interp_hur(xx,yy,zz-1,nt) +
     +     r*(interp_hur(xx,yy,zz-1,nt+1)-interp_hur(xx,yy,zz-1,nt))

        end if

        end if

        end do

        if(interp_tos(xx,yy,nt).ne.1e+20) then

         interp_SST3h(xx,yy,tt) = interp_tos(xx,yy,nt) +
     +    r*(interp_tos(xx,yy,nt+1)-interp_tos(xx,yy,nt))

         end if

        if(interp_ts(xx,yy,nt).ne.1e+20) then

        interp_SKINTEMP3h(xx,yy,tt) = interp_ts(xx,yy,nt) +
     +    r*(interp_ts(xx,yy,nt+1)-interp_ts(xx,yy,nt))
  
        end if
        
        end do
        end do
        end do
        END

