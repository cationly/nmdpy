function kptcart = create_kptlist(  latvec, Nx, Ny, Nz )

%create kptlist 
cnt=1;
for ix=(-(Nx/2)+1):1:(Nx/2)
    for iy=(-(Ny/2)+1):1:(Ny/2)
        for iz=(-(Nz/2)+1):1:(Nz/2)            
        integer(cnt,:) = [ix iy iz];
        kptcart(cnt,1:3) = ix/Nx*latvec(1,:) +...
            iy/Ny*latvec(2,:) +...
            iz/Nz*latvec(3,:) ;
        cnt=cnt+1;
        end
    end
end
