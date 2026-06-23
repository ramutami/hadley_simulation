
module parameters_and_variables_for_simulation
    implicit none
    real(8), parameter :: pi = atan(1.0d0)*4.0d0
    !gloval_parameters
        !global定数：すべてのmoduleのsubroutineで参照可能な変数

        !------------change allowed--------------!
        real(8) :: nu = 25.0d0 !粘性、色々変えたりする。
        real(8),parameter :: z_max=8.0d3 !子午面の高さ[m]
        integer,parameter :: j_max=180 !緯度方向の格子数
        integer,parameter :: k_max=50 !z方向の格子数
        real(8),parameter :: delta_t = 300.0d0 !時間積分間隔[s]
        real(8),parameter :: max_t = 20.0d0 * 86400.0d0 !時間積分の打ち切り時間[s]

        real(8),parameter :: a = 6.4d6!地球半径[m]
        real(8),parameter :: Omega = 2.0d0*pi/8.64d4 !自転
        real(8),parameter :: tau = 20.0d0 * 86400.0d0 !realxation time[s],
        real(8),parameter :: g  = 9.8d0!重力加速度
        real(8),parameter :: Delta_H = 1.0d0/3.0d0
        real(8),parameter :: Delta_v = 1.0d0/8.0d0
        real(8),parameter :: C_drag = 0.005d0 !摩擦
        !------------change allowed--------------!

        real(8),parameter :: H = z_max
        real(8),parameter :: dtheta  = pi/real(j_max,8) !緯度方向の格子幅Delta_theta
        real(8),parameter :: dz = H/real(k_max,8) !z方向の格子幅Delta_z
        integer,parameter :: it_max = floor(max_t/delta_t)!時間ステップの最大数

    !

    !global_variables
        !global変数：すべてのmoduleのsubroutineで参照可能な変数

        real(8),allocatable :: u(:,:)
        real(8),allocatable :: u_mid(:,:) !松野スキームにおける中間ステップ出力
        real(8),allocatable :: v(:,:)
        real(8),allocatable :: v_mid(:,:)
        real(8),allocatable :: pot_temp(:,:) !正規化された温位
        real(8),allocatable :: pot_temp_mid(:,:) 
        real(8),allocatable :: pot_temp_E(:,:)
        real(8),allocatable :: w(:,:)
        real(8),allocatable :: Phi_diff(:,:) !ポテンシャルPhiのtheta微分
        real(8),allocatable :: theta(:) !緯度

    !

    contains
    subroutine allocate_variables() 
        implicit none   
        integer :: j

        allocate(u(-1:j_max,-1:k_max))
        allocate(u_mid(-1:j_max,-1:k_max))
        allocate(v(0:j_max,-1:k_max))
        allocate(v_mid(0:j_max,-1:k_max))
        allocate(pot_temp(-1:j_max,-1:k_max))
        allocate(pot_temp_mid(-1:j_max,-1:k_max))
        allocate(pot_temp_E(0:j_max-1,0:k_max-1))
        allocate(w(0:j_max-1,0:k_max))
        allocate(Phi_diff(0:j_max-1,0:k_max))
        allocate(theta(-1:j_max))

        do j = lbound(theta,1),ubound(theta,1)
            theta(j) = -pi/2.0d0 + (j+0.5d0)*dtheta
        end do

    end subroutine allocate_variables


end module parameters_and_variables_for_simulation

module initialization 
    use parameters_and_variables_for_simulation
    implicit none

    contains
    subroutine initialize_pot_temp_E
        implicit none
        integer :: j,k
        real(8) :: p2,z


        do k = lbound(pot_temp_E,2),ubound(pot_temp_E, dim=2)
            z = (real(k,8)+0.5d0) * dz
            do j = lbound(pot_temp_E,1),ubound(pot_temp_E, dim=1)
                p2 = 0.5d0*(3.0d0*sin(theta(j))**2-1.0d0)
                pot_temp_E(j,k) = 1.0d0 - (2.0d0/3.0d0) * Delta_H * p2 + Delta_v * (z/H - 0.5d0)
            end do
        end do

    end subroutine initialize_pot_temp_E

    subroutine initialize_field
        implicit none
        integer :: j,k

        u = 0.0d0
        u_mid = 0.0d0
        v = 0.0d0
        v_mid = 0.0d0

        do k = lbound(pot_temp_E,2),ubound(pot_temp_E, dim=2)
        do j = lbound(pot_temp_E,1),ubound(pot_temp_E, dim=1)
            pot_temp(j,k) = pot_temp_E(j,k)
        end do
        end do

        pot_temp_mid = 0.0d0
        w = 0.0d0
        Phi_diff = 0.0d0
    end subroutine initialize_field
end module initialization

module update_variables
    use parameters_and_variables_for_simulation
    implicit none

    contains 

    subroutine update_u(u_in,v_in,w_in,u_n,u_out) 
        implicit none
        real(8),intent(in) :: u_in(-1:j_max,-1:k_max) 
        real(8),intent(in) :: v_in(0:j_max,-1:k_max)
        real(8),intent(in) :: w_in(0:j_max-1,0:k_max)
        real(8),intent(in) :: u_n(-1:j_max,-1:k_max)
        real(8),intent(out) :: u_out(-1:j_max,-1:k_max)

        integer :: j,k
        real(8) :: term1,term2,term3,term4,term5

        do k = 0,k_max-1
        do j = 0,j_max-1
            term1 = -1.0d0/(a*cos(theta(j))) *( (u_in(j,k)+u_in(j+1,k))/2.0d0 * v_in(j+1,k)*cos(0.5d0*(theta(j+1)+theta(j))) &
            & - (u_in(j-1,k)+u_in(j,k))/2.0d0 * v_in(j,k)*cos(0.5d0*(theta(j)+theta(j-1))) ) / dtheta
            term2 = -1.0d0* (0.5d0*(u_in(j,k)+u_in(j,k+1))*w_in(j,k+1)-0.5d0*(u_in(j,k-1)+u_in(j,k))*w_in(j,k))/dz
            term3 = 2.0d0 * Omega * sin(theta(j)) * 0.5d0*(v_in(j,k)+v_in(j+1,k))
            term4 = (u_in(j,k)*0.5d0*(v_in(j,k)+v_in(j+1,k))*tan(theta(j)))/a
            term5 = nu/dz * ((u_in(j,k+1)-u_in(j,k))/dz - (u_in(j,k)-u_in(j,k-1))/dz)
            u_out(j,k) = u_n(j,k) + delta_t * (term1 + term2 + term3 + term4 + term5)
        end do
        end do

    end subroutine update_u

    subroutine update_v(u_in,v_in,w_in,Phi_diff_in,v_n,v_out)
        implicit none
        real(8),intent(in) :: u_in(-1:j_max,-1:k_max) 
        real(8),intent(in) :: v_in(0:j_max,-1:k_max)
        real(8),intent(in) :: w_in(0:j_max-1,0:k_max)
        real(8),intent(in) :: Phi_diff_in(0:j_max-1,0:k_max)
        real(8),intent(in) :: v_n(0:j_max,-1:k_max)
        real(8),intent(out) :: v_out(0:j_max,-1:k_max)

        integer :: j,k
        real(8) :: term1,term2,term3,term4,term5,term6

        do k = 0,k_max-1
            do j = 1,j_max-1
                term1 = -1.0d0/(a*cos(0.5d0*(theta(j-1)+theta(j)))) * ((0.5d0*(v_in(j,k) + v_in(j+1,k)))**2 * cos(theta(j))-(0.5d0*(v_in(j-1,k) + v_in(j,k)))**2 * cos(theta(j-1)))/dtheta
                term2 = -1.0d0 * (0.5d0*(w_in(j-1,k+1) + w_in(j,k+1))*0.5d0*(v_in(j,k+1)+v_in(j,k))-0.5d0*(w_in(j-1,k) + w_in(j,k))*0.5d0*(v_in(j,k)+v_in(j,k-1)))/dz
                term3 = -2.0d0*Omega*sin(0.5d0*(theta(j-1)+theta(j))) * 0.5d0*(u_in(j,k)+u_in(j-1,k))
                term4 = -1.0d0 * (0.5d0*(u_in(j,k) + u_in(j-1,k)))**2 * tan(0.5d0*(theta(j-1)+theta(j)))/a
                term5 = -1.0d0/a/4.0d0 * (Phi_diff_in(j-1,k) + Phi_diff_in(j-1,k+1) + Phi_diff_in(j,k) + Phi_diff_in(j,k+1))
                term6 = nu/dz/dz * (v_in(j,k+1)-v_in(j,k)-v_in(j,k)+v_in(j,k-1))
                v_out(j,k) = v_n(j,k) + delta_t * (term1 + term2 + term3 + term4 + term5 + term6)
            end do

            v_out(0,k) = 0.0d0
            v_out(j_max,k) = 0.0d0
        
        end do

    end subroutine update_v

    subroutine update_potential_temperature(v_in,w_in,pot_temp_in,pot_temp_E,pot_temp_n,pot_temp_out)
        implicit none
        real(8),intent(in) :: v_in(0:j_max,-1:k_max)
        real(8),intent(in) :: w_in(0:j_max-1,0:k_max)
        real(8),intent(in) :: pot_temp_in(-1:j_max,-1:k_max)
        real(8),intent(in) :: pot_temp_E(0:j_max-1,0:k_max-1)
        real(8),intent(in) :: pot_temp_n(-1:j_max,-1:k_max)
        real(8),intent(out) :: pot_temp_out


    end subroutine update_potential_temperature


end module update_variables

module update_boundary
    use parameters_and_variables_for_simulation
    implicit none

    contains 

    subroutine update_boundary_u(u_in)
        implicit none
        real(8),intent(inout) :: u_in(-1:j_max,-1:k_max)
        integer :: j,k

        do k=0,k_max-1
            u_in(-1,k) = u_in(0,k)
            u_in(j_max,k) = u_in(j_max-1,k)
        end do

        do j=-1,j_max
            u_in(j,k_max) = u_in(j,k_max-1)
            u_in(j,-1) = (nu/dz - C_drag/2.0d0)/(nu/dz + C_drag/2.0d0)*u_in(j,0)
        end do
    end subroutine update_boundary_u

    subroutine update_boundary_v(v_in)
        implicit none
        integer :: j
        real(8),intent(inout) :: v_in(0:j_max,-1:k_max)

        do j = 0,j_max
            v_in(j,k_max) = v_in(j,k_max-1)
            v_in(j,-1) = (nu/dz - C_drag/2.0d0)/(nu/dz + C_drag/2.0d0)*v_in(j,0)
        end do

    end subroutine update_boundary_v

end module update_boundary


program main
    use parameters_and_variables_for_simulation
    use initialization
    use update_variables
    use update_boundary
    implicit none
    integer :: it



    call allocate_variables()
    call initialize_pot_temp_E()
    call initialize_field()

    call update_u(u_in=u, v_in=v, w_in=w, u_n=u, u_out=u_mid)
    call update_boundary_u(u_in=u_mid)
    call update_v(u_in=u,v_in=v,w_in=w,Phi_diff_in=Phi_diff,v_n=v,v_out=v_mid)
    call update_boundary_v(v_in=v_mid)

end program main
