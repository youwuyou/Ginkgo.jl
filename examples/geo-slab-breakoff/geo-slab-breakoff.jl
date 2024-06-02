using Ginkgo
using LinearAlgebra, SparseArrays
using Plots, Plots.Measures
using LaTeXStrings

ENV["GKSwstype"]="nul"; if isdir("viz2D_out")==false mkdir("viz2D_out") end; loadpath = "./viz2D_out/"; anim = Animation(loadpath,String[])
println("Animation directory: $(anim.dir)")

# flipping only the y-axis for the correct y=axis definition
default(size=(6300,3300),fontfamily="Computer Modern", linewidth=4, framestyle=:box, margin=5mm, yflip=true)
scalefontsizes(); scalefontsizes(4.0)


DO_VIZ = false
with_ginkgo = true
const (Tv, Ti) = (Float64, Int32)

if with_ginkgo == true
    # Print ginkgo library version
    Ginkgo.version()
end

#==== SOME OTHER NOTES

Note that viscosity for
shear (ηs) and normal (ηn) stresses is interpolated separately to the basic nodes and
cell centres, respectively (Fig. 11.2)



====#




"""Slab breakoff (slab detachment)

General Theory:  Slab breakoff is a process during which a part of subducted slab detaches from
subducting plate. It significates the termination of the subduction. 

The necking portion of the slab is the weakest and the most stressful portion. Necking
is essentially 'thining' of the slab. After some time the eduction takes place, 

at the end dense portion of the slab representing
oceanic crust sinks deeper into the mantle. This detachment happens relatively quickly,
within 1-2 Myr.


The behavior how the slab breakoff takes place also depends on the age of the oceanic plate
and the rate of the plate movement. The elder the plate is, the colder is the temperature.

Simulation: Our simulation takes place right after the continential collision starts.
We introduce the visco-plastic rheology


"""
function slab_breakoff()

    # GEOMETRY
    xsize = 500000 # 500km
    ysize = 400000 # 400km
    Nx    = 101
    Ny    = 81
    dx    = xsize / (Nx-1)
    dy    = ysize / (Ny-1)

    # location of the interfaces which divide the domain horizontally, denoted the y-coordinates
    # parallel to x-axis
    x1    = 0.44 * xsize # x1 = 220
    x2    = 0.46 * xsize # x2 = 230
    x3    = 0.54 * xsize # x3 = 270
    x4    = 0.56 * xsize # x4 = 280
    x5    = 0.66 * xsize # x5 = 330
    x6    = 0.74 * xsize # x6 = 370
    x7    = 0.86 * xsize # x7 = 430

    # parallel to y-axis
    y1 = 0.125 * ysize # air-plate interface at    y = 50 km
    y2 = 0.25  * ysize # plate-mantle interface at y = 100 km
    y3 = 0.375 * ysize # ending of the necking area y = 150 km
    y4 = 0.625 * ysize # ending of the slab y = 250 km


    slab_upper_boundary(y) = x1 + (y-y2) * (x2-x1)/(y1-y2)
    slab_left_boundary(y)  = x1 + (y-y2) * (x6-x1)/(y4-y2)
    slab_right_boundary(y) = x2 + (y-y1) * (x7-x2)/(y4-y1)


    # STAGGERED GRID
    x   = 0:dx:xsize+dx        # Horizontal   [m]
    y   = 0:dy:ysize+dy        # Vertical     [m]
    xvx = 0:dx:xsize+dx
    yvx = -dy/2:dy:ysize+dy/2
    xvy = -dx/2:dx:xsize+dx/2   
    yvy = 0:dy:ysize+dy        
    xpr = -dx/2:dx:xsize+dx/2
    ypr = -dy/2:dy:ysize+dy/2


    # INTERPOLATED PROPERTIES
    # mechanical
    ETAb    = zeros(Ny+1, Nx+1)
    ETAp    = zeros(Ny+1, Nx+1)   # not used in visu in ref!
    RHOvy   = zeros(Ny+1, Nx+1)

    EXY     = zeros(Ny+1,Nx+1)     # ɛₓᵧ^·
    SXY     = zeros(Ny+1,Nx+1)     # σₓᵧ'
    EXX     = zeros(Ny+1,Nx+1)     # ɛₓₓ^·
    EYY     = zeros(Ny+1,Nx+1)     # ɛᵧᵧ^·
    SXX     = zeros(Ny+1,Nx+1)     # σₓₓ'
    SYY     = zeros(Ny+1,Nx+1)     # σᵧᵧ'

    # for subgrid diffusion
    DT          = zeros(Ny+1, Nx+1)
    DTremaining = zeros(Ny+1, Nx+1)
    DTsubgrid   = zeros(Ny+1, Nx+1)

    # thermal
    Kvx     = zeros(Ny+1, Nx+1)
    Kvy     = zeros(Ny+1, Nx+1)    # not visualized in ref!
    RHOcpp  = zeros(Ny+1, Nx+1)
    T0p     = zeros(Ny+1, Nx+1)
    Tdt     = zeros(Ny+1, Nx+1)
    RHOp    = zeros(Ny+1, Nx+1)
    ALPHAp  = zeros(Ny+1, Nx+1)
    Hrp     = zeros(Ny+1, Nx+1)
    Hap     = zeros(Ny+1, Nx+1)
    Hsp     = zeros(Ny+1, Nx+1)

    # CONCRETE VALUES FOR PHYSICAL PROPERTIES
    # physical properties
    gy                      = 10.0
    rho_air                 = 1.0          # density kg/m^3
    rho_dry                 = 3400.0
    rho_wet                 = 3250.0
    eta_air                 = 1.0e+18      # viscosity Pa·s
    eta_dry                 = 1.0e+23
    eta_wet                 = 1.0e+20
    T_air                   = 273.0        # temperature K
    T_mantle                = 1573.0
    Cp_air                  = 3300000.0    # heat capacity J/K/kg
    Cp_rock                 = 1000.0
    k_air                   = 3000.0       # thermal conductivity W/m/K
    Hr_air                  = 0.0          # heating terms W/m^3
    Hr_dry                  = 2.0e-8
    Hr_wet                  = 3.0e-8
    alpha_air               = 0.0          # 1/K
    alpha_rock              = 3.0e-5
    beta_air                = 0.0
    beta_rock               = 1.0e-11      # 1/Pa
    
    # defining stengths Pa i.e. σyield for plastic rheology
    strength_plate_slab     = 1.0e+8
    strength_necking        = 2.0e+7
    strength_mantle         = 5.0e+7

    T_plate(y)              = T_air + (y - y1) * (T_mantle - T_air) / (y2 - y1)
    T_slab(d)               = d * (1573-273)/(60000/sqrt(2)) + 273.0
    k_rock(T)               = 0.73 + 1293.0 / (T + 77.0)

    # MARKERS
    # using 25 markers per 2D marker cell
    Nxm    = (Nx-1) * 5
    Nym    = (Ny-1) * 5
    Nm     = Nxm * Nym
    xm     = zeros(1,Nm)
    ym     = zeros(1,Nm)
    dxm    = xsize/Nxm      # not Nxm-1 for more distance on boundaries
    dym    = ysize/Nym
    
    # NEW: introducing marker type
    # 1 ↔ air
    # 2 ↔ mantle        (wet olivine)
    # 3 ↔ slab/plate    (dry olivine)
    # 4 ↔ necking area  (dry olivine)
    typem  = zeros(1,Nm)  
    RHOm   = zeros(1, Nm)      # Density   ρₘ
    ETAm   = zeros(1, Nm)      # Viscosity ηₘ
    RHOcpm = zeros(1, Nm)      # Volumetric heat capacity ρCpₘ
    Tm     = zeros(1, Nm)      # Temperature Tₘ
    Km     = zeros(1, Nm)      # Conductivity kₘ
    Hrm    = zeros(1, Nm)      # Temperature Tₘ
    ALPHAm = zeros(1, Nm)      # Thermal expansion, for computig Ha
    BETAm  = zeros(1, Nm)

    # NEW nonlinear rheology
    Pm          = zeros(1, Nm)
    EXXm        = zeros(1, Nm)
    EYYm        = zeros(1, Nm)
    EXYm        = zeros(1, Nm)
    EIIm        = zeros(1, Nm)
    SIGMAyieldm = zeros(1, Nm)
    


    m = 1  # start of the index m ∈ {1,2,,Nm} 
    for jm in 1:1:Nxm
        for im in 1:1:Nym

            # dis-/enable randomization
            xm[m] = dxm * 0.5 + (jm-1) * dxm #=+ (rand() - 0.5) * dxm=#
            ym[m] = dym * 0.5 + (im-1) * dym #=+ (rand() - 0.5) * dym=#

            if (ym[m] < y1)
                # sticky air - type 1
                typem[m]       = 1
                RHOm[m]        = rho_air
                RHOcpm[m]      = RHOm[m] * Cp_air
                ETAm[m]        = eta_air
                Tm[m]          = T_air
                Km[m]          = k_air
                Hrm[m]         = Hr_air
                ALPHAm[m]      = alpha_air
                BETAm[m]       = beta_air
                SIGMAyieldm[m] = 0.0
                
            elseif (y2 < ym[m] && ym[m] < ysize)
                # mantle - type 2
                typem[m]       = 2
                RHOm[m]        = rho_wet
                RHOcpm[m]      = RHOm[m] * Cp_rock
                ETAm[m]        = eta_wet
                Tm[m]          = T_mantle
                Km[m]          = k_rock(Tm[m])
                Hrm[m]         = Hr_wet
                ALPHAm[m]      = alpha_rock
                BETAm[m]       = beta_rock
                SIGMAyieldm[m] = strength_mantle

                # beneath the interface between plate and the slab
                # only the parallelogram-like region for both necking area
                if (ym[m] < y4 && slab_left_boundary(ym[m]) < xm[m] && xm[m] < slab_right_boundary(ym[m]))

                    # and the lower part of the slab
                    RHOm[m]       = rho_dry
                    ETAm[m]       = eta_dry
                    dist_to_right = slab_right_boundary(ym[m]) - xm[m]
                    Tm[m]         = T_slab(dist_to_right / sqrt(2))
                    Km[m]         = k_rock(Tm[m])
                    Hrm[m]        = Hr_dry

                    if (ym[m] < y3)
                        # necking area lower strength
                        typem[m]       = 4
                        RHOcpm[m]      = RHOm[m] * Cp_rock
                        SIGMAyieldm[m] = strength_necking
                    else
                        # lower part of the slab higher strength
                        typem[m]  = 3
                        RHOcpm[m] = RHOm[m] * Cp_rock
                        SIGMAyieldm[m] = strength_plate_slab
                    end

                end

            else 
                # plate (only the square part) - type 3
                #(y1 <= ym[m] && ym[m] <= y2)
                typem[m]       = 3
                RHOm[m]        = rho_dry
                RHOcpm[m]      = RHOm[m] * Cp_rock
                ETAm[m]        = eta_dry
                Tm[m]          = T_plate(ym[m])
                Km[m]          = k_rock(Tm[m])
                Hrm[m]         = Hr_dry
                ALPHAm[m]      = alpha_rock
                BETAm[m]       = beta_rock
                SIGMAyieldm[m] = strength_plate_slab

                # above the interface between plate and the slab
                # only the triangular region
                if (slab_upper_boundary(ym[m]) < xm[m] && xm[m] < slab_right_boundary(ym[m]))
                    dist_to_right = slab_right_boundary(ym[m]) - xm[m]
                    Tm[m]         = T_slab(dist_to_right / sqrt(2))
                    Km[m]         = k_rock(Tm[m])
                end            

            end

            m = m + 1  # marker increment
        end
    end



    # timestepping
    ntimesteps = 10

    # define global matrices for stokes a priori for efficiency
    n = (Ny + 1) * (Nx + 1) * 3  # global number of unknowns
    L = zeros(n,n)           # LHS
    R = zeros(n,1)           # RHS
    if with_ginkgo        
        S = Vector{Tv}(undef, n);
        fill!(S, 0.0)
    end

    Vx = zeros(Ny+1, Nx+1)
    Vy = zeros(Ny+1, Nx+1)
    Pr = zeros(Ny+1, Nx+1)


    # define global matrices for the heat eq a priori for efficiency
    nt = (Ny+1) * (Nx+1)  # global number of unknowns
    LT = zeros(nt,nt)           # LHS
    RT = zeros(nt,1)            # RHS

    if with_ginkgo
        ST = Vector{Tv}(undef, nt);
        fill!(ST, 0.0)
    end


    # boundary conditions
    # free slip on all 4 boundaries of the squared domain
    is_free_slip = true

    if (is_free_slip == true)
        bc = -1            #   free slip   vx1 = 0, vy1 = vy2
    else
        bc = 1             #   no-slip     vx1 = 0, vy1 = -vy2
    end


    # TIME STEPPING
    dt         = 1.0e+11
    dispmax    = 0.5
    Tchangemax = 50.0
    timesum    = 0.0


    for timestep in 1:1:ntimesteps

        ################## INTERPOLATION MARKER START ########################

        # i).   Density RHOvy
        # ii).  Viscosity ETAb, ETAp
        # iii). Thermal conductivity Kvx, Kvy
        # iv).  Volumetric heat capacity RHOcpp
        # v).   Temperature T0p
        # vi).  Heating terms ALPHAp, Hrp

        # basic nodes
        WTSUMb      = zeros(Ny+1, Nx+1)
        ETAWTSUMb   = zeros(Ny+1, Nx+1)

        # vx nodes
        WTSUMvx     = zeros(Ny+1, Nx+1)
        KVXWTSUMvx  = zeros(Ny+1, Nx+1)  # Kvx

        # vy nodes
        WTSUMvy     = zeros(Ny+1, Nx+1)
        RHOWTSUMvy  = zeros(Ny+1, Nx+1)  # RHOvy
        KVYWTSUMvy  = zeros(Ny+1, Nx+1)  # Kvy

        # pressure nodes
        WTSUMp      = zeros(Ny+1, Nx+1)
        ETAWTSUMp   = zeros(Ny+1, Nx+1) # ETAp
        RHOCPWTSUMp = zeros(Ny+1, Nx+1) # RHOcpp
        RHOWTSUMp   = zeros(Ny+1, Nx+1) # RHOp for computing adiabatic terms!
        TWTSUMp     = zeros(Ny+1, Nx+1) # T0p
        ALPHAWTSUMp = zeros(Ny+1, Nx+1) # alpha for Ha
        HRWTSUMp    = zeros(Ny+1, Nx+1) # Hr



        # going through markers on the 2D grid
        for m in 1:1:Nm

            # edge case check: only interpolate markers within the grid
            if (xm[m] >= 0 && xm[m] <= xsize && ym[m] >= 0 && ym[m] <= ysize)

                # 1). Basic nodes:  ETAb
                #   ηₘ => ETAb     this is basic-node
                #                     /
                #   ETAb(i, j)       o--------o ETAb(i, j+1)
                #                  | * m    |
                #                 |        |
                #   ETAb(i+1, j)  o--------o ETAb(i+1, j+1)       
    
                # Indices
                i = trunc(Int, (ym[m] - y[1])/dy) + 1
                j = trunc(Int, (xm[m] - x[1])/dx) + 1
    
                # obtain relative distance ΔXm(j) from the marker to node
                q_x = abs(xm[m]-x[j])/dx   # distance quotient in x-direction
                q_y = abs(ym[m]-y[i])/dy   # distance quotient in y-direction
                
                # adding up weights
                Wtmij   = (1. - q_x) * (1. - q_y)
                Wtmi1j  = (1. - q_x) * q_y
                Wtmij1  =  q_x * (1. - q_y)
                Wtmi1j1 =  q_x * q_y
    
                WTSUMb[i,j]        = WTSUMb[i,j] + Wtmij        # Upper left  ↔ Wtmij
                WTSUMb[i, j+1]     = WTSUMb[i, j+1] + Wtmij1    # Upper right ↔ Wtmi1j
                WTSUMb[i+1,j]      = WTSUMb[i+1,j] + Wtmi1j     # Lower left  ↔ Wtmij1
                WTSUMb[i+1,j+1]    = WTSUMb[i+1,j+1] + Wtmi1j1  # Lower right ↔ Wtmi1j1
    
                # ETAb
                ETAWTSUMb[i,j]     = ETAWTSUMb[i,j] + ETAm[m] * Wtmij          # Upper left ↔ Wtmij
                ETAWTSUMb[i,j+1]   = ETAWTSUMb[i,j+1] + ETAm[m] * Wtmij1       # Upper right ↔ Wtmi1j
                ETAWTSUMb[i+1,j]   = ETAWTSUMb[i+1,j] + ETAm[m] * Wtmi1j       # Lower left ↔ Wtmij1
                ETAWTSUMb[i+1,j+1] = ETAWTSUMb[i+1,j+1] + ETAm[m] * Wtmi1j1    # Lower right ↔ Wtmi1j1
    

                # 2). Vx-node:  Kvx
                #     ρₘ => RHO       this is vx-node
                #                     /
                #    Kvx(i, j)       o--------o Kvx(i, j+1)
                #                   | * m    |
                #                  |        |
                #    Kvx(i+1, j)  o--------o Kvx(i+1, j+1)       
                i = trunc(Int, (ym[m] - yvx[1])/dy) + 1
                j = trunc(Int, (xm[m] - xvx[1])/dx) + 1
    
                q_x = abs(xm[m]-xvx[j])/dx
                q_y = abs(ym[m]-yvx[i])/dy
                
                Wtmij   = (1. - q_x) * (1. - q_y)
                Wtmi1j  = (1. - q_x) * q_y
                Wtmij1  =  q_x * (1. - q_y)
                Wtmi1j1 =  q_x * q_y
    
                WTSUMvx[i,j]        = WTSUMvx[i,j] + Wtmij   
                WTSUMvx[i, j+1]     = WTSUMvx[i, j+1] + Wtmij1
                WTSUMvx[i+1,j]      = WTSUMvx[i+1,j] + Wtmi1j
                WTSUMvx[i+1,j+1]    = WTSUMvx[i+1,j+1] + Wtmi1j1
    
                KVXWTSUMvx[i,j]     = KVXWTSUMvx[i,j] + Km[m] * Wtmij           # Upper left ↔ Wtmij     
                KVXWTSUMvx[i,j+1]   = KVXWTSUMvx[i,j+1] + Km[m] * Wtmij1        # Upper right ↔ Wtmi1j
                KVXWTSUMvx[i+1,j]   = KVXWTSUMvx[i+1,j] +   Km[m] * Wtmi1j      # Lower left ↔ Wtmij1
                KVXWTSUMvx[i+1,j+1] = KVXWTSUMvx[i+1,j+1] +  Km[m] * Wtmi1j1    # Lower right ↔ Wtmi1j1
        
    
    
                # 3). Vy-node:  RHOvy, Kvy
                #     ρₘ => RHO       this is vy-node
                #                     /
                #   RHO(i, j)       o--------o RHO(i, j+1)
                #                  | * m    |
                #                 |        |
                #   RHO(i+1, j)  o--------o RHO(i+1, j+1)       
                i = trunc(Int, (ym[m] - yvy[1])/dy) + 1
                j = trunc(Int, (xm[m] - xvy[1])/dx) + 1
    
                q_x = abs(xm[m]-xvy[j])/dx
                q_y = abs(ym[m]-yvy[i])/dy
                
                Wtmij   = (1. - q_x) * (1. - q_y)
                Wtmi1j  = (1. - q_x) * q_y
                Wtmij1  =  q_x * (1. - q_y)
                Wtmi1j1 =  q_x * q_y
    
                WTSUMvy[i,j]        = WTSUMvy[i,j] + Wtmij   
                WTSUMvy[i, j+1]     = WTSUMvy[i, j+1] + Wtmij1
                WTSUMvy[i+1,j]      = WTSUMvy[i+1,j] + Wtmi1j
                WTSUMvy[i+1,j+1]    = WTSUMvy[i+1,j+1] + Wtmi1j1

                # RHOvy
                RHOWTSUMvy[i,j]     = RHOWTSUMvy[i,j] + RHOm[m] * Wtmij           # Upper left ↔ Wtmij     
                RHOWTSUMvy[i,j+1]   = RHOWTSUMvy[i,j+1] + RHOm[m] * Wtmij1        # Upper right ↔ Wtmi1j
                RHOWTSUMvy[i+1,j]   = RHOWTSUMvy[i+1,j] +   RHOm[m] * Wtmi1j      # Lower left ↔ Wtmij1
                RHOWTSUMvy[i+1,j+1] = RHOWTSUMvy[i+1,j+1] +  RHOm[m] * Wtmi1j1


                # Kvy
                KVYWTSUMvy[i,j]     = KVYWTSUMvy[i,j] + Km[m] * Wtmij           # Upper left ↔ Wtmij     
                KVYWTSUMvy[i,j+1]   = KVYWTSUMvy[i,j+1] + Km[m] * Wtmij1        # Upper right ↔ Wtmi1j
                KVYWTSUMvy[i+1,j]   = KVYWTSUMvy[i+1,j] +   Km[m] * Wtmi1j      # Lower left ↔ Wtmij1
                KVYWTSUMvy[i+1,j+1] = KVYWTSUMvy[i+1,j+1] +  Km[m] * Wtmi1j1    # Lower right ↔ Wtmi1j1



                # 4). pressure nodes: T0p
                #   ηₘ => ETAp     this is pr-node
                #                     /
                #   ETAp(i, j)       o--------o ETAp(i, j+1)
                #                  | * m    |
                #                 |        |
                #   ETAp(i+1, j)  o--------o ETAp(i+1, j+1)       
                i = trunc(Int, (ym[m] - ypr[1])/dy) + 1
                j = trunc(Int, (xm[m] - xpr[1])/dx) + 1

                q_x = abs(xm[m] - xpr[j]) / dx
                q_y = abs(ym[m] - ypr[i]) / dy

                Wtmij   = (1. - q_x) * (1. - q_y)
                Wtmi1j  = (1. - q_x) * q_y
                Wtmij1  = q_x * (1. - q_y)
                Wtmi1j1 = q_x * q_y

                WTSUMp[i,j] = WTSUMp[i,j] + Wtmij
                WTSUMp[i,j+1] = WTSUMp[i,j+1] + Wtmij1
                WTSUMp[i+1,j] = WTSUMp[i+1,j] + Wtmi1j
                WTSUMp[i+1,j+1] = WTSUMp[i+1,j+1] + Wtmi1j1

                # ETAp
                ETAWTSUMp[i,j]     = ETAWTSUMp[i,j] + ETAm[m] * Wtmij          # Upper left ↔ Wtmij
                ETAWTSUMp[i,j+1]   = ETAWTSUMp[i,j+1] + ETAm[m] * Wtmij1       # Upper right ↔ Wtmij1
                ETAWTSUMp[i+1,j]   = ETAWTSUMp[i+1,j] + ETAm[m] * Wtmi1j       # Lower left ↔ Wtmi1j
                ETAWTSUMp[i+1,j+1] = ETAWTSUMp[i+1,j+1] + ETAm[m] * Wtmi1j1    # Lower right ↔ Wtmi1j1

                # RHOcpp
                RHOCPWTSUMp[i,j]     = RHOCPWTSUMp[i,j] + RHOcpm[m] * Wtmij
                RHOCPWTSUMp[i,j+1]   = RHOCPWTSUMp[i,j+1] + RHOcpm[m] * Wtmij1
                RHOCPWTSUMp[i+1,j]   = RHOCPWTSUMp[i+1,j] + RHOcpm[m] * Wtmi1j
                RHOCPWTSUMp[i+1,j+1] = RHOCPWTSUMp[i+1,j+1] + RHOcpm[m] * Wtmi1j1

                # T0p: special for T comparing to other properties!
                TWTSUMp[i,j]     = TWTSUMp[i,j] + Tm[m] * RHOcpm[m] * Wtmij
                TWTSUMp[i,j+1]   = TWTSUMp[i,j+1] + Tm[m] * RHOcpm[m] * Wtmij1
                TWTSUMp[i+1,j]   = TWTSUMp[i+1,j] + Tm[m] * RHOcpm[m] * Wtmi1j
                TWTSUMp[i+1,j+1] = TWTSUMp[i+1,j+1] + Tm[m] * RHOcpm[m] * Wtmi1j1

                # ALPHAp
                ALPHAWTSUMp[i,j]     = ALPHAWTSUMp[i,j] + ALPHAm[m] * Wtmij
                ALPHAWTSUMp[i,j+1]   = ALPHAWTSUMp[i,j+1] + ALPHAm[m] * Wtmij1
                ALPHAWTSUMp[i+1,j]   = ALPHAWTSUMp[i+1,j] + ALPHAm[m] * Wtmi1j
                ALPHAWTSUMp[i+1,j+1] = ALPHAWTSUMp[i+1,j+1] + ALPHAm[m] * Wtmi1j1
                
                # RHOp: for computing Ha
                RHOWTSUMp[i,j]     = RHOWTSUMp[i,j] + RHOm[m] * Wtmij
                RHOWTSUMp[i,j+1]   = RHOWTSUMp[i,j+1] + RHOm[m] * Wtmij1
                RHOWTSUMp[i+1,j]   = RHOWTSUMp[i+1,j] + RHOm[m] * Wtmi1j
                RHOWTSUMp[i+1,j+1] = RHOWTSUMp[i+1,j+1] + RHOm[m] * Wtmi1j1

                # Hrp
                HRWTSUMp[i,j]     = HRWTSUMp[i,j] + Hrm[m] * Wtmij
                HRWTSUMp[i,j+1]   = HRWTSUMp[i,j+1] + Hrm[m] * Wtmij1
                HRWTSUMp[i+1,j]   = HRWTSUMp[i+1,j] + Hrm[m] * Wtmi1j
                HRWTSUMp[i+1,j+1] = HRWTSUMp[i+1,j+1] + Hrm[m] * Wtmi1j1


            end


        end # end of marker summation


        # COMPUTE ETA, RHO
        # Mechanical
        # 1). RHOvy ↔ y-stokes  => ρₘ   on vy nodes
        # 2). ETAb ↔ x,y-stokes => ηₘ   on basic nodes
        # 3). ETAp ↔ x,y-stokes => ηₘ   on pressure nodes
    
        # Thermo
        # 4). Kvx ↔ x-heat flux => Kₘ   on vx nodes
        # 5). Kvy ↔ y-heat flux => Kₘ   on vy nodes
        # 6). RHOcpp ↔ heat conservation => ρCₚₘ on pressure nodes
        # 7). RHOp ↔ for computing Ha  => ρₘ   on pressure nodes
        # 8). T0p ↔ heat conservation => Tₘ on pressure nodes
        # 9). ALPHAp  ↔ heating terms => ɑₘ on pressure nodes
        # 10). Hrp     ↔ heating terms => Hrₘ on pressure nodes    
        for j in 1:1:Nx+1
            for i in 1:1:Ny+1

                # b-nodes
                if (WTSUMb[i,j] > 0)
                    ETAb[i,j]   = ETAWTSUMb[i,j] / WTSUMb[i,j]
                end

                # vx-nodes
                if (WTSUMvx[i,j] > 0)
                    Kvx[i,j]   = KVXWTSUMvx[i,j] / WTSUMvx[i,j]
                end

                # vy-nodes
                if (WTSUMvy[i,j] > 0)
                    RHOvy[i,j] = RHOWTSUMvy[i,j] / WTSUMvy[i,j]
                    Kvy[i,j]   = KVYWTSUMvy[i,j] / WTSUMvy[i,j]
                end

                # pressure nodes
                if (WTSUMp[i,j] > 0)
                    ETAp[i,j]   = ETAWTSUMp[i,j] / WTSUMp[i,j]
                    RHOcpp[i,j] = RHOCPWTSUMp[i,j] / WTSUMp[i,j]
                    T0p[i,j]    = TWTSUMp[i,j] / RHOCPWTSUMp[i,j]
                    ALPHAp[i,j] = ALPHAWTSUMp[i,j] / WTSUMp[i,j]
                    RHOp[i,j]   = RHOWTSUMp[i,j] / WTSUMp[i,j]
                    Hrp[i,j]    = HRWTSUMp[i,j] / WTSUMp[i,j]
                end

            end
        end

        ################## INTERPOLATION MARKER END  ##########################

        # Apply boundary conditions for the nodal temperatures
        # interpolated from markers
        # Upper/lower/left/right
        # NOTE: note not applying B.C to the outermost rows, since we defined T on the pressure nodes
        #  x   x   x   x
        #  -------------  ˿ T = Ttop
        #  x   x   x   x
        T0p[1,2:Nx]    .= 2 * T_air .- T0p[2,2:Nx]     # Dirichlet
        T0p[Ny+1,2:Nx] .= 2 * T_mantle .- T0p[Ny,2:Nx] # Dirichlet

        T0p[:,1]    = T0p[:,2]   # Insulating boundary
        T0p[:,Nx+1] = T0p[:,Nx]  # Insulating boundary       
        

        ############## THERMO-MECH ITERATION START  ####################

        # solve the stokes with thermomechanical iteration 
        # compute the stress and strain rate
        # compute the heating terms for adiabatic and shear heating
        # solve the heat equation
        # compute the temp difference
        
        # Introducing thermomechanical iteration
        # => multiphysics siulation tradeoff: more expensive but for correctness
    
        nitermax = 2

        # probing increase of the time step
        dt        = dt*1.1   # coeff 1.1 implies gradual increase in the time step size)

        # adjust the timestep within the iterations
        for niter in 1:1:nitermax

            ################## STOKES SOLVING START ########################
            # compose global matrix L and the RHS R
            for j in 1:1:Nx+1
                for i in 1:1:Ny+1
                    # global Indices
                    kvx = ((j-1) * (Ny+1) + i - 1) * 3 + 1
                    kvy = kvx + 1
                    kpr = kvx + 2


                    # equation for Vx
                    if (j == Nx+1)
                        # ghost nodes
                        L[kvx, kvx] = 1
                        R[kvx,1]    = 0

                    elseif (i == 1 || i == Ny+1 || j == 1 || j == Nx)
                        # real B.C.
                        L[kvx,kvx]  = 1
                        # FIXME: 
                        # R[kvx, 1]   = 0
                        R[kvx]   = 0                  

                        if (i == 1 && j > 1 && j < Nx)
                            L[kvx, kvx+3] = bc
                        elseif (i == Ny+1 && j>1 && j<Nx)
                            L[kvx, kvx-3] = bc 
                        end

                    else
                        # internal - x-stokes
                        # η · (∂2Vx/∂x2 + ∂2Vx/∂y2) - ∂P/∂x = 0
                        # 
                        #
                        #            Stencil
                        #              Vx2
                        #               |
                        #        Vy1----|----Vy3
                        #               |
                        #  Vx1---P1----Vx3----P2---Vx5
                        #               |
                        #        Vy2----|----Vy4
                        #               |
                        #              Vx4
                        # Viscosity points
                        ETA1=ETAb[i-1,j]
                        ETA2=ETAb[i,j]
                        ETAP1=ETAp[i,j]
                        ETAP2=ETAp[i,j+1]

                        L[kvx,kvx-(Ny+1)*3] = 2 * ETAP1/dx^2                                             # Vx1
                        L[kvx,kvx-3]        = ETA1/dy^2                                                # Vx2
                        L[kvx,kvx]          = -2*(ETAP1 + ETAP2)/dx^2-(ETA1+ETA2)/dy^2  # Vx3  
                        L[kvx,kvx+3]        = ETA2/dy^2                                                  # Vx4
                        L[kvx,kvx+(Ny+1)*3] = 2 * ETAP2/dx^2                                            # Vx5
        
                        L[kvx,kvy-3]          = ETA1/dx/dy             # Vy1
                        L[kvx,kvy]            =-ETA2/dx/dy               # Vy2
                        L[kvx,kvy+(Ny+1)*3-3] =-ETA1/dx/dy              # Vy3
                        L[kvx,kvy+(Ny+1)*3]   = ETA2/dx/dy                # Vy4
        
                        L[kvx,kpr]            =  1/dx                    # P1
                        L[kvx,kpr+(Ny+1)*3]   = -1/dx                    # P2
            
                        # Right part
                        R[kvx,1]=0

                    end


                    # equation for Vy
                    if (i == Ny+1)
                        # ghost nodes
                        L[kvy, kvy] = 1
                        R[kvy,1]    = 0

                    elseif (i == 1 || i == Ny || j == 1 || j == Nx+1)
                        # real B.C.
                        L[kvy,kvy]  = 1
                        R[kvy]   = 0  #FIXME: changed!

                        if (j == 1 && i > 1 && i < Ny)
                            L[kvy, kvy+3*(Ny+1)]  = bc
                        elseif (j == Nx+1 && i>1 && i<Ny) # FIXME: changed from j<Ny to i<Ny
                            L[kvy, kvy-3*(Ny+1)]  = bc 
                        end

                    else
                        # internal - y-stokes
                        # η · (∂2Vy/∂x2 + ∂2Vy/∂y2) - ∂P/∂y 
                        #                           - Vx · ∂ρ_t0/∂x · Δt · gy
                        #                           - Vy · ∂ρ_t0/∂y · Δt · gy
                        #                                   = - ρ_t0 · gy
                        #
                        #            Stencil
                        #              Vy2
                        #               |
                        #        Vx1---PA---Vx3
                        #               |
                        # Vy1---σyx1'--Vy3--σyx2'--Vy5
                        #               |
                        #        Vx2---PB---Vx4
                        #               |
                        #              Vy4
                        # density gradient
                        ETA1  = ETAb[i, j-1]
                        ETA2  = ETAb[i, j]
                        ETAP1 = ETAp[i, j]
                        ETAP2 = ETAp[i+1, j]
    
                        # density gradient
                        dRHOdx = (RHOvy[i, j+1] - RHOvy[i, j-1]) / 2 / dx  # for all four Vx nodes
                        dRHOdy = (RHOvy[i+1, j] - RHOvy[i-1, j]) / 2 / dy  # for only the Vy3
    
                        # - Vy · ∂ρ_t0/∂y · Δt · gy
                        ycorr = -dRHOdy * gy * dt
                        L[kvy, kvy-(Ny+1)*3]   = ETA1 / dx^2                 # Vy1
                        L[kvy, kvy-3]          = 2.0 * ETAP1 / dy^2            # Vy2
                        L[kvy, kvy]            = -2.0 * (ETAP1 + ETAP2) / dy^2 -
                                                  (ETA1 + ETA2) / dx^2  +
                                                  ycorr                        # Vy3
                        L[kvy, kvy+3]          = 2.0 * ETAP2 / dy^2            # Vy4
                        L[kvy, kvy+(Ny+1)*3]   = ETA2 / dx^2                 # Vy5
    
                        # - Vx · ∂ρ_t0/∂x · Δt · gy
                        xcorr                 = -dRHOdx * gy * dt / 4.0
                        L[kvy, kvx-(Ny+1)*3]   = ETA1 / dx / dy + xcorr       # Vx1
                        L[kvy, kvx+3-(Ny+1)*3] = -ETA1 / dx / dy + xcorr      # Vx2
                        L[kvy, kvx]            = -ETA2 / dx / dy + xcorr      # Vx3
                        L[kvy, kvx+3]          = ETA2 / dx / dy + xcorr       # Vx4
    
                        L[kvy, kpr]            = 1.0 / dy                       # PA
                        L[kvy, kpr+3]          = -1.0 / dy                      # PB
    
                        # Right part
                        R[kvy, 1]              = -RHOvy[i, j] * gy

                    end

                    # equation for Pr
                    if (i == 1 || i == Ny+1 || j == 1 || j == Nx + 1)
                        # ghost nodes
                        L[kpr, kpr] = 1.;
                        R[kpr,1]    = 0.;
                    
                    elseif (i == 2 && j == 2)
                        # real BC
                        L[kpr, kpr] = 1.;
                        R[kpr,1]    = 1.0e+5;     # pressure boundary condition                        
                    else
                        # internal - continuity equation
                        #  
                        #   ∂Vx/∂x + ∂Vy/∂y = 0
                        #   (Vx2-Vx1)/dx + (Vy2-Vy1)/dy = 0
                        #
                        #            Stencil
                        #              Vy1 (i-1,j)
                        #               |
                        #    (i,j-1)    |       (i,j)
                        #       Vx1---- P ---- Vx2
                        #               |
                        #               |
                        #              Vy2 (i,j)
                        # Left part
                        L[kpr,kvx-(Ny+1)*3] =-1.0/dx;    # Vx1
                        L[kpr,kvx]          = 1.0/dx;    # Vx2
                        L[kpr,kvy-3]        =-1.0/dy;    # Vy1
                        L[kpr,kvy]          = 1.0/dy;    # Vy2
                        
                        # Right part
                        R[kpr,1] = 0.0;
                    end



                end
            end # end of matrix assembling

            # Solving global matrices
            if with_ginkgo
                # Use sparse direct
                solver = GkoDirectSolver(:lu_direct, sparse(L))
                Ginkgo.apply!(solver, vec(R), S)
            else
                S = sparse(L) \ R
            end


            # FIXME: missing these three lines?
            # fill!(Vx, 0.0)
            # fill!(Vy, 0.0)
            # fill!(Pr, 0.0)

            # Reload solution to Pr, Vx, Vy
            for j in 1:1:Nx+1
                    for i in 1:1:Ny+1
                        # global indices
                        kvx = ((j-1) * (Ny+1) + (i-1)) * 3 + 1
                        kvy = kvx + 1
                        kpr = kvx + 2

                        # reload solution
                        Vx[i,j] = S[kvx]
                        Vy[i,j] = S[kvy]
                        Pr[i,j] = S[kpr]
                    end
            end

            ################## STOKES SOLVING END ########################
            # DEFINE ADAPTIVE TIMESTEPS FOR MARKER DISPLACEMENT

            # Restrictions: <= 0.5 dx  && <= 0.5 dy
            # Using the max' to define the timesteps
            if (niter<nitermax)
                Vxmax = maximum(abs.(Vx));   # using two max functions because of 2D
                Vymax = maximum(abs.(Vy));

                if (dt > (dispmax * dx) / Vxmax)
                    dt = dispmax * dx / Vxmax;
                    # DEBUG: enable it to check the mechanical timestep size
                    # dtmechanicalvx = dt
                end

                if (dt > (dispmax * dy) / Vymax)
                    dt = dispmax * dy / Vymax;
                    # DEBUG: enable it to check the mechanical timestep size
                    # dtmechanicalvy = dt
                end

            end


            # COMPUTE ADIABATIC AND SHEAR HEATING
            for j in 1:1:Nx
                for i in 1:1:Ny
                    # Stencil
                    #               Vx(i,j)
                    #                 ·    Basic node
                    #                 |    / 
                    #                 |   /
                    #  Vy(i,j)·--- σₓᵧ',ɛₓᵧ^·----Vy(i,j+1)
                    #                 |
                    #                 |
                    #                 ·
                    #              Vx(i+1,j)

                    # computation of deviatoric stresses and strain rates on basic nodes
                    EXY[i,j]   = 1/2*((Vx[i+1,j]-Vx[i,j])/dy + (Vy[i,j+1] - Vy[i,j])/dx);  # ɛₓᵧ^·
                    SXY[i,j]   = 2*ETAb[i,j]*EXY[i,j];                                     # σₓᵧ'
                end
            end

            for j = 2:1:Nx
                for i = 2:1:Ny
                    # Stencil
                    #    j-1                         j
                    #               Vy(i-1,j)                i-1
                    #                 ·    Pressure node
                    #                 |    / 
                    #                 |   /
                    #  Vx(i,j-1)·--- σₓₓ',ɛₓₓ^·----Vx(i,j)
                    #                 |
                    #                 |
                    #                 ·
                    #              Vy(i,j)                  i

                    # computation of deviatoric stresses and strain rates on pressure nodes
                    EXX[i,j]   = (Vx[i,j]-Vx[i,j-1])/dx;     # ɛₓₓ^·
                    EYY[i,j]   = (Vy[i,j]-Vy[i-1,j])/dy;     # ɛᵧᵧ^·
                    SXX[i,j]   = 2*ETAp[i,j]*EXX[i,j];       # σₓₓ'
                    SYY[i,j]   = 2*ETAp[i,j]*EYY[i,j];       # σᵧᵧ'
                    
                    # compute the heating terms after solving stokes from stress
                    # i). adiabatic heating (semi-implicit) Ha = TɑρgᵧVᵧ
                    Hap[i,j] = ALPHAp[i,j]*RHOp[i,j]*gy*(Vy[i,j]+Vy[i-1,j])/2.0;

                    # ii). shear heating Hs = σₓₓ'ɛₓₓ^· + σᵧᵧ'ɛᵧᵧ^· + 2σₓᵧ'ɛₓᵧ^·
                    # taking average of the products for SXY*EXY products
                    Hsp[i,j] = SXX[i,j]*EXX[i,j] + SYY[i,j]*EYY[i,j] +
                            2* (SXY[i-1,j-1]*EXY[i-1,j-1] + SXY[i-1,j]*EXY[i-1,j] +
                                SXY[i,j-1]*EXY[i,j-1] + SXY[i,j]*EXY[i,j])/4.0;
                end
            end


            ################## THERMAL SOLVING START #####################
            for j in 1:1:Nx+1
                for i in 1:1:Ny+1
                    # Define global index kt
                    kt  = (j-1) * (Ny+1) + i;

                    # Equations for T
                    if (i == 1 || i == Ny+1 || j == 1 || j == Nx + 1)

                        if (i == 1)
                            # external nodes at the upper boundary (Dirichlet)
                            LT[kt,kt]      = 0.5;
                            LT[kt,kt+1]    = 0.5;
                            RT[kt,1]       = T_air; # T_top
                        end 

                        if (i == Ny+1)
                            # external nodes at the lower boundary (Dirichlet)
                            LT[kt,kt]      = 0.5;
                            LT[kt,kt-1]    = 0.5;
                            RT[kt,1]       = T_mantle;  # T_bottom
                        end

                        if (j == 1 && i > 1 && i < Ny+1)
                            # external nodes at the left boundary (Neumann)
                            LT[kt,kt]        = 1;
                            LT[kt,kt+(Ny+1)] = -1;
                            RT[kt,1]         = 0;
                        end
                        
                        if (j==Nx+1 && i > 1 && i < Ny+1)
                            # external nodes at the right boundary (Neumann)
                            LT[kt,kt]        = 1;
                            LT[kt,kt-(Ny+1)] = -1;
                            RT[kt,1]         = 0;
                        end                

                    else
                        # Heat conservation equation
                        # · ρCₚ DT/Dt + ∂qₓ/∂x + ∂qy/∂x = Hr+Ha+Hs
                        #       · qₓ:= -k_qₓ · ∂T/∂x
                        #       · qᵧ:= -k_qᵧ · ∂T/∂y
                        #
                        # Discretized
                        #   ρCₚ T3/dt + (qx2-qx1)/dx + (qy2-qy1)/dy = ρCₚ T3⁰/dt + Hr + Ha + Hs
                        #       · qx1 = -2 Kvx(i,j-1)·(T3-T1)/dx
                        #       · qx2 = -2 Kvx(i,j)·(T5-T3)/dx
                        #       · qy1 = -2 Kvy(i-1,j)·(T3-T2)/dy
                        #       · qy2 = -2 Kvy(i,j) ·(T4-T3)/dy
                        #
                        #
                        #                T2
                        #                |
                        #               qy1
                        #                |
                        #              (i,j)     
                        #   T1---qx1----T3----qx2---T5
                        #               |
                        #              qy2
                        #               |
                        #              T4
                        # ORIGINAL
                        LT[kt,kt-(Ny+1)]   = -Kvx[i,j-1]/dx^2; # T1
                        LT[kt,kt-1]        = -Kvy[i-1,j]/dy^2; # T2
                        LT[kt,kt]          = RHOcpp[i,j]/dt + (Kvx[i,j-1]+Kvx[i,j])/dx^2 +
                                                            (Kvy[i-1,j]+Kvy[i,j])/dy^2 -
                                                            Hap[i,j]/2.0; # T3 NEW
                        LT[kt,kt+1]        = -Kvy[i,j]/dy^2; # T4
                        LT[kt,kt+(Ny+1)]   = -Kvx[i,j]/dx^2; # T5
                            

                        # RHS
                        # With heating terms (NEW!)
                        # Hr -> Hrp constant property obtained from interpolated markers
                        # Ha -> Ha = Tɑ DP/Dt
                        # Hs -> compute from the stress
                        #       Hs = σₓₓ'·ɛₓₓ'^· + σᵧᵧ'·ɛᵧᵧ'^· + 2·σₓᵧ'·ɛₓᵧ'^·
                        RT[kt,1] = RHOcpp[i,j]/dt * T0p[i,j] + Hrp[i,j] + Hsp[i,j] + T0p[i,j]*Hap[i,j]/2.0;
                    end
                    
                end
            end # ST assembly end
            
            
            # Solving global matrices
            if with_ginkgo
                # Use sparse direct
                solver = GkoDirectSolver(:lu_direct, sparse(LT))
                Ginkgo.apply!(solver, vec(RT), ST)
            else
                ST = sparse(LT) \ RT;
            end
            
            ################## THERMAL SOLVING END #######################
            # reload the solution
            for j in 1:1:Nx+1
                for i in 1:1:Ny+1
                    # global index for current node
                    kt  = (j-1) * (Ny+1) + i;
                    Tdt[i,j] = ST[kt];
                    Hap[i,j] = Hap[i,j] * (T0p[i,j]+Tdt[i,j])/2.0;   # NEW, used to recover Ha
                end
            end


            # DT for interpolation to avoid numerical diffusion
            DT = Tdt - T0p;
            
            # DEFINE ADAPTIVE TIMESTEP FOR TEMPERATURE EQUATION
            # (NEW!) No timestep change during the last iteration
            if (niter < nitermax)
                DTmax = maximum(abs.(DT));
            
                if (DTmax > Tchangemax)
                    # adjustment: decrease the timestep size
                    # for safty make dt 10# less than the allowed upper bound
                    dt = dt * Tchangemax/DTmax/1.1;
            
                    # FIXME: DEBUG: enable it to check thermal timestep
                    dtthermal = dt;
                end
            end

        end # end of thermal-mechanical iterations

        # reset T0 for next step
        T0p = Tdt;

        ############## THERMO-MECH ITERATION END  ######################


        # SUBGRID DIFFUSION
        # decompose ΔTm := ΔTmsubgrid + ΔTmremaining
        DTWTSUMp     = zeros(Ny+1, Nx+1)
        RHOCPWTSUMp  = zeros(Ny+1, Nx+1)
        for m in 1:1:Nm
            # edge case check: only interpolate markers within the grid
            if (xm[m] >= 0 && xm[m] <= xsize && ym[m] >= 0 && ym[m] <= ysize)

                # Pressure nodes:  (ETAp), RHOcpp, T0p 
                i = trunc(Int, (ym[m] - ypr[1])/dy) + 1;
                j = trunc(Int, (xm[m] - xpr[1])/dx) + 1;
                
                q_x = abs(xm[m]-xpr[j])/dx;
                q_y = abs(ym[m]-ypr[i])/dy;
                
                Wtmij   = (1. - q_x) * (1. - q_y);
                Wtmi1j  = (1. - q_x) * q_y;
                Wtmij1  =  q_x * (1. - q_y);
                Wtmi1j1 =  q_x * q_y;
                
                # compute marker-node temperature difference ΔT0m⁰
                DTsubgrid0 = Tm[m] 
                            - (T0p[i,j] * Wtmij + T0p[i+1,j] * Wtmi1j +
                            T0p[i,j+1] * Wtmij1 + T0p[i+1, j+1] * Wtmi1j1)

                # Relax temperature difference by subgrid diffusion, where Δt := t
                # ΔTm(t) = ΔTm(Δt) - ΔTm⁰
                #        = ΔTm⁰·exp(-(2km)/(ρm·Cpm)·(1/Δx²+1/Δy²)t) - ΔTm⁰      
                DTmsubgrid1 = DTsubgrid0 * exp(-2*Km[m]/(RHOcpm[m])*(1/dx^2 + 1/dy^2)*dt) - DTsubgrid0

                # correct the marker temperature
                Tm[m] = Tm[m] + DTmsubgrid1

                # Update subgrid diffusion on nodes
                DTWTSUMp[i,j]     = DTWTSUMp[i,j] + DTmsubgrid1 * RHOcpm[m] * Wtmij
                DTWTSUMp[i,j+1]   = DTWTSUMp[i,j+1] + DTmsubgrid1 * RHOcpm[m] * Wtmij1
                DTWTSUMp[i+1,j]   = DTWTSUMp[i+1,j] + DTmsubgrid1 * RHOcpm[m] * Wtmi1j
                DTWTSUMp[i+1,j+1] = DTWTSUMp[i+1,j+1] + DTmsubgrid1 * RHOcpm[m] * Wtmi1j1
                
                RHOCPWTSUMp[i,j]     = RHOCPWTSUMp[i,j] + RHOcpm[m] * Wtmij
                RHOCPWTSUMp[i,j+1]   = RHOCPWTSUMp[i,j+1] + RHOcpm[m] * Wtmij1
                RHOCPWTSUMp[i+1,j]   = RHOCPWTSUMp[i+1,j] + RHOcpm[m] * Wtmi1j
                RHOCPWTSUMp[i+1,j+1] = RHOCPWTSUMp[i+1,j+1] + RHOcpm[m] * Wtmi1j1
            
            end # edge case check end
        end
        
        
        
        # interpolate ΔTmsubgrid back to ΔTsubgrid        
        for j in 1:1:Nx+1
            for i in 1:1:Ny+1
                # update only when sum > 0
                if (RHOCPWTSUMp[i,j] > 0)
                    DTsubgrid[i,j]    = DTWTSUMp[i,j] / RHOCPWTSUMp[i,j]
                end
            end
        end


        
        # compute DTremaining from DT and DTsubgrid
        DTremaining = DT - DTsubgrid
        
        
        ################## THERMAL INTERP START #######################
        # ORIGINAL interpolate for the heat equation from nodal points to markers
        # NEW! We also interpolate for the nodal values of non-linear rheology
      
        for m in 1:1:Nm
            # edge case check: only interpolate markers within the grid
            if (xm[m] >= 0 && xm[m] <= xsize && ym[m] >= 0 && ym[m] <= ysize)
                
                # Pressure nodes:  (ETAp), RHOcpp, T0p 
                i = trunc(Int, (ym[m] - ypr[1])/dy) + 1;
                j = trunc(Int, (xm[m] - xpr[1])/dx) + 1;
                
                q_x = abs(xm[m]-xpr[j])/dx;
                q_y = abs(ym[m]-ypr[i])/dy;
                
                Wtmij   = (1. - q_x) * (1. - q_y);
                Wtmi1j  = (1. - q_x) * q_y;
                Wtmij1  =  q_x * (1. - q_y);
                Wtmi1j1 =  q_x * q_y;
                
                # update for heat equation
                # NEW: interpolate nodal values of DTremaining to markers in order to add its contribution
                # the DT subgrid was added already
                Tm[m] = Tm[m] + 
                        (DTremaining[i,j] * Wtmij + DTremaining[i+1,j] * Wtmi1j +
                         DTremaining[i,j+1] * Wtmij1 + DTremaining[i+1, j+1] * Wtmi1j1)

                # FIXME: Old
                # Tm[m] = Tm[m] + 
                #         DT[i,j] * Wtmij    + DT[i+1,j] * Wtmi1j + 
                #         DT[i,j+1] * Wtmij1 + DT[i+1,j+1] * Wtmi1j1;
                    

                if (timestep == 1)
                    # interpolate Tm(m) at 1st time step
                    # for consistency of values at nodal points and markers
                    Tm[m] = Tdt[i,j] * Wtmij 
                          + Tdt[i+1,j] * Wtmi1j 
                          + Tdt[i,j+1] * Wtmij1 
                          + Tdt[i+1,j+1] * Wtmi1j1;
                end
            
            end


        end

        ################### THERMAL INTERP END ########################

    







        ################### RHEOLOGY INTERP START ########################
        
        for m in 1:1:Nm
            
            # edge case check: only interpolate markers within the grid
            if (xm[m] >= 0 && xm[m] <= xsize && ym[m] >= 0 && ym[m] <= ysize)
                
                i = trunc(Int, (ym[m] - ypr[1])/dy) + 1;
                j = trunc(Int, (xm[m] - xpr[1])/dx) + 1;
                
                q_x = abs(xm[m]-xpr[j])/dx;
                q_y = abs(ym[m]-ypr[i])/dy;
                
                Wtmij   = (1. - q_x) * (1. - q_y);
                Wtmi1j  = (1. - q_x) * q_y;
                Wtmij1  =  q_x * (1. - q_y);
                Wtmi1j1 =  q_x * q_y;
                
                # APPLY NODAL VALUES OF VISCO-PLASTIC RHEOLOGY 
                # pressure, normal strain rate
                Pm[m]   =   Pr[i,j] * Wtmij    + Pr[i+1,j] * Wtmi1j + 
                            Pr[i,j+1] * Wtmij1 + Pr[i+1,j+1] * Wtmi1j1;
                
                EXXm[m] =   EXX[i,j] * Wtmij    + EXX[i+1,j] * Wtmi1j + 
                            EXX[i,j+1] * Wtmij1 + EXX[i+1,j+1] * Wtmi1j1;
                
                EYYm[m] =   EYY[i,j] * Wtmij    + EYY[i+1,j] * Wtmi1j + 
                            EYY[i,j+1] * Wtmij1 + EYY[i+1,j+1] * Wtmi1j1;
                
     
                # Basic nodes
                i = trunc(Int, (ym[m] - y[1])/dy) + 1
                j = trunc(Int, (xm[m] - x[1])/dx) + 1
                
                # obtain relative distance ΔXm(j) from the marker to node
                q_x = abs(xm[m]-x[j])/dx   # distance quotient in x-direction
                q_y = abs(ym[m]-y[i])/dy   # distance quotient in y-direction
                
                # adding up weights
                Wtmij   = (1. - q_x) * (1. - q_y)
                Wtmi1j  = (1. - q_x) * q_y
                Wtmij1  =  q_x * (1. - q_y)
                Wtmi1j1 =  q_x * q_y

                EXYm[m] =   EXY[i,j] * Wtmij    + EXY[i+1,j] * Wtmi1j + 
                            EXY[i,j+1] * Wtmij1 + EXY[i+1,j+1] * Wtmi1j1;
                    
                # second strain rate invariant
                EIIm[m] = sqrt((EXXm[m]^2 + EYYm[m]^2)/2 + EXYm[m]^2)

                
                if (typem[m] != 1)

                    # OLIVINE CREEP - representing the mantle rheology                    
                    if (typem[m] == 2)
                        # mantle wet olivine
                        #= The weak zone is prescibed as a wet brittle/plastic fault within mantle rocks
                        characterized by wet olivine
                        During subduction, the pre-defined weak zone is spontaneously replaced by
                        weak subducted crustal rocks, thereby preserving the decoupling along the surface
                        =#
                        AD   = 2.0e-21
                        n    = 4.0
                        Va   = 4.0e-6     # activation volume
                        Ea   = 471000.0
                        RHO0 = 3300.0
                    else
                        # dry olivine
                        AD   = 2.5e-17    # 1/Pa^n_dry/s
                        n    = 3.5        
                        Va   = 8.0e-6     
                        Ea   = 532000.0   # J/mol
                        RHO0 = 3400.0
                    end

                    Km[m]     = k_rock(Tm[m])
                    ETAm[m]   = 0.5/AD^(1.0/n)*EIIm[m]^(1.0/n-1)*exp((Ea+Pm[m]*Va)/(8.314*Tm[m]*n))
                    RHOm[m]   = RHO0*(1+BETAm[m]*(Pm[m]-1.0e+5))/(1+ALPHAm[m]*(Tm[m]-273.0))
                    RHOcpm[m] = RHOm[m] * Cp_rock


                    if (ETAm[m]*2.0*EIIm[m] > SIGMAyieldm[m])
                        ETAm[m] = SIGMAyieldm[m] / 2.0 / EIIm[m]
                    end

                    
                    # controlling values of viscosity using predefined limits
                    ETAmin = 1e+18 # Pa·s
                    ETAmax = 1e+24 # Pa·s
                    
                    if (ETAm[m] < ETAmin)
                        ETAm[m] = ETAmin
                    elseif (ETAm[m] > ETAmax)
                        ETAm[m] = ETAmax
                    end



                end # end of eta and rho, rhocp computation for rocks


            end # end of edge case check
                    
        end # end of marker interpolation
                
                
        ################### RHEOLOGY INTERP END ########################
                
                


        ##################### ADVECTION START ########################
        # ADVECT LAGRANGIAN MARKERS        
        # NOTE: previously dt was defined here when solving only stokes,
        # now we need to define dt before the thermal solver

        # Using Runge Kutta 4th order scheme
        Vxm = zeros(4,1);
        Vym = zeros(4,1);
                
        dt_weights = [0., 0.5, 0.5, 1.];
        
        # advect the markers
        for m in 1:1:Nm
            
            # Store xA, yA for each new marker
            xA = xm[m];
            yA = ym[m];
            
            # Using loop for computations of the RK-coeff (velocities A,B,C,D)
            for rk in 1:1:4
                # STEP 1: obtain weights at markers m for Vx
                # Stencil
                # Vx(i, j)    o--------o Vx(i, j+1)
                #             | * m    |
                #             |        |
                # Vx(i+1, j)  o--------o Vx(i+1, j+1)       
                
    
                # obtain the indices i,j
                P_x = xA;
                P_y = yA;
    
                if (rk != 1)
                    P_x = P_x + dt_weights[rk] * dt * Vxm[rk-1];
                    P_y = P_y + dt_weights[rk] * dt * Vym[rk-1];
                end
    
                i = trunc(Int, (P_y - yvx[1])/dy) + 1;
                j = trunc(Int, (P_x - xvx[1])/dx) + 1;
    
                    # check indices
                    if (i < 1)
                        i = 1;      # first cell
                    end
                    
                    if (j < 1)
                        j = 1;      # first cell
                    elseif (j > Nx-1)
                        j = Nx-1;    # last cell
                    end
    
    
                # obtain relative distance ΔXm(j) from the marker to node
                q_x = abs(P_x-xvx[j])/dx;   # distance quotient in x-direction
                q_y = abs(P_y-yvx[i])/dy;   # distance quotient in y-direction
    
    
                # compute weights
                Wtmij   = (1. - q_x) * (1. - q_y);
                Wtmi1j  = (1. - q_x) * q_y;
                Wtmij1  =  q_x * (1. - q_y);
                Wtmi1j1 =  q_x * q_y;
    
    
                # add the correction term for Vx
                if (P_x <= dx/2.) || (P_x >= xsize - dx/2.)
                    dVxmcorr = 0.;
                else
                    if (q_x <= 0.5)
                        dVxmcorr = 0.5 * (q_x - 0.5)^2 * 
                                    ((1.0-q_y) * (Vx[i,j-1] - 2 * Vx[i,j] + Vx[i,j+1]) + 
                                    q_y * (Vx[i+1,j-1] - 2 * Vx[i+1,j] + Vx[i+1,j+1]));
                    else
                        dVxmcorr = 0.5 * (q_x - 0.5)^2 * 
                                    ((1.0-q_y) * (Vx[i,j] - 2 * Vx[i,j+1] + Vx[i,j+2]) + 
                                    q_y * (Vx[i+1,j] - 2 * Vx[i+1,j+1] + Vx[i+1,j+2]));
                    end
    
                end
    
                # INTERPOLATION
                # using bilinear interpolation
                # => ensures the sum of weight equals to one
                Vxm[rk] = Vx[i,j] * Wtmij + 
                        Vx[i,j+1] * Wtmij1 + 
                        Vx[i+1,j] * Wtmi1j + 
                        Vx[i+1,j+1] * Wtmi1j1 + dVxmcorr;
    
                # STEP 2: obtain weights at markers m for Vy
                # Stencil
                # Vy(i, j)    o--------o Vy(i, j+1)
                #             | * m    |
                #             |        |
                # Vy(i+1, j)  o--------o Vy(i+1, j+1)       
    
                # obtain the indices i,j
                i = trunc(Int, (P_y - yvy[1])/dy) + 1;
                j = trunc(Int, (P_x - xvy[1])/dx) + 1;
    
    
                # check indices
                if (i < 1)
                    i = 1;      # first cell
                elseif (i > Ny-1)
                    i = Ny-1;    # last cell
                end
    
                if (j < 1)
                    j = 1;      # first cell
                end
    
    
                # obtain relative distance ΔXm(j) from the marker to node
                q_x = abs(P_x-xvy[j])/dx;   # distance quotient in x-direction
                q_y = abs(P_y-yvy[i])/dy;   # distance quotient in y-direction
    
                # adding up weights
                Wtmij   = (1. - q_x) * (1. - q_y);
                Wtmi1j  = (1. - q_x) * q_y;
                Wtmij1  =  q_x * (1. - q_y);
                Wtmi1j1 =  q_x * q_y;
    
    
                # add the correction term for Vy
                if (P_y <= dy/2.) || (P_y >= ysize - dy/2.)
                    dVymcorr = 0.;
                else
                    if (q_y <= 0.5)
                        dVymcorr = 0.5 * (q_y - 0.5)^2 * 
                        ((1-q_x) * (Vy[i-1,j] - 2 * Vy[i,j] + Vy[i+1,j]) + 
                            q_x * (Vy[i-1,j+1] - 2 * Vy[i,j+1] + Vy[i+1,j+1]));
                    else
                        dVymcorr = 0.5 * (q_y - 0.5)^2 * 
                                    ((1-q_x) * (Vy[i,j] - 2 * Vy[i+1,j] + Vy[i+2,j]) + 
                                    q_x * (Vy[i,j+1] - 2 * Vy[i+1,j+1] + Vy[i+2,j+1]));
                    end
                end
    
                # INTERPOLATION
                # using bilinear interpolation
                # => ensures the sum of weight equals to one
                Vym[rk] = Vy[i,j] * Wtmij + 
                        Vy[i,j+1] * Wtmij1 + 
                        Vy[i+1,j] * Wtmi1j + 
                        Vy[i+1,j+1] * Wtmi1j1 + dVymcorr;
    
    
            end # end of the RK coeff loop
    
            # Use Vxmeff and Vymeff instead
            Vxmeff = (Vxm[1] + 2. * Vxm[2] + 2.0* Vxm[3] + Vxm[4]) / 6.0;
            Vymeff = (Vym[1] + 2. * Vym[2] + 2.0* Vym[3] + Vym[4]) / 6.0;
    
            # Dx/Dt = vx
            xm[m] = xm[m] + Vxmeff * dt;   # x_n+1 = x_n + Vx * dt
            ym[m] = ym[m] + Vymeff * dt;   # y_n+1 = y_n + Vy * dt
    
        end
        ##################### ADVECTION END ########################

        timesum = timesum + dt

        println("Iteration: ", timestep)


        # visualization
        if DO_VIZ
            p1 = heatmap(xvy, yvy, RHOvy, aspect_ratio=1, xlims=(extrema(xvy)), ylims=(extrema(yvy)), c=:turbo, title="Density " * L"\rho, kg/m^3", interpolate = true)
            p2 = heatmap(x, y, log10.(ETAb), aspect_ratio=1, xlims=(extrema(x)), ylims=(extrema(y)), c=:turbo, title=L"\log_{10}(ETAb), Pa\cdot s", interpolate = true)
            p3 = heatmap(xpr, ypr,  Tdt, aspect_ratio=1, xlims=(extrema(xpr)), ylims=(extrema(ypr)), c=:turbo, title="Temperature, K", interpolate = true)
            p4 = heatmap(xpr, ypr, Pr, aspect_ratio=1, xlims=(extrema(xpr)), ylims=(extrema(ypr)), c=:turbo, title="Pressure, Pa", interpolate = true)
            p5 = heatmap(xvx, yvx, Vx, aspect_ratio=1, xlims=(extrema(xvx)), ylims=(extrema(yvx)), c=:turbo, title="Vx, m/s", interpolate = true)
            p6 = heatmap(xvy, yvy, Vy, aspect_ratio=1, xlims=(extrema(xvy)), ylims=(extrema(yvy)), c=:turbo, title="Vy, m/s", interpolate = true)
            p7 = heatmap(xpr, ypr,  RHOcpp, aspect_ratio=1, xlims=(extrema(xpr)), ylims=(extrema(ypr)), c=:turbo, title="RHOcpp, " * L"J/K/m^3")
            p8 = heatmap(xvx, yvx,  log10.(Kvx), aspect_ratio=1, xlims=(extrema(xvx)), ylims=(extrema(yvx)), c=:turbo, title=L"\log_{10}(Kvx), W/m/K", interpolate = true)
            p9 = heatmap(xpr, ypr,  ALPHAp, aspect_ratio=1, xlims=(extrema(xpr)), ylims=(extrema(ypr)), c=:turbo, title="ALPHA, 1/K", interpolate = true)
            p10 = heatmap(xpr, ypr,  Hrp, aspect_ratio=1, xlims=(extrema(xpr)), ylims=(extrema(ypr)), c=:turbo, title="Hr, " * L"W/m^3", interpolate = true)
            p11 = heatmap(xpr, ypr,  Hsp, aspect_ratio=1, xlims=(extrema(xpr)), ylims=(extrema(ypr)), c=:turbo, title="Hs, " * L"W/m^3", interpolate = true)
            p12 = heatmap(xpr, ypr,  Hap, aspect_ratio=1, xlims=(extrema(xpr)), ylims=(extrema(ypr)), c=:turbo, title="Ha, " * L"W/m^3", interpolate = true)

            display(plot(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, layout=(3,4))); frame(anim)

            # Debug
            println("Vx[27,12] = ", Vx[27,12])
            println("Vy[27,12] = ", Vy[27,12])
            println("Pr[27,12] = ", Pr[27,12])
            println("Tdt[27,12] = ", Tdt[27,12])
            println("Hrp[27,12] = ", Hrp[27,12])
            println("Hap[27,12] = ", Hap[27,12])
            println("Hsp[27,12] = ", Hsp[27,12])
            println("Δt = ", dt)
        end
    end # end of the timestepping

    if DO_VIZ
        gif(anim, "geo-slab-breakoff.gif", fps = 1)
    end

end

if with_ginkgo
    # Creates executor for a specific backend
    exec = create(:omp)
    Ginkgo.with(EXECUTOR => exec) do
        @time slab_breakoff();
    end
else
    @time slab_breakoff()
end





