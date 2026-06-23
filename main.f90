
module parameters_and_variables_for_simulation
    implicit none


    !gloval_parameters
        !global定数：すべてのmoduleのsubroutineで参照可能な変数

        !------------change allowed--------------!
        real(8),parameter :: z_max !子午面の高さ
        real(8),parameter :: j_max !緯度方向の格子数
        real(8),parameter :: k_max !z方向の格子数
        real(8)
        
        !------------change allowed--------------!

        real(8),parameter :: dtheta !緯度方向の格子幅Delta_theta
        real(8),parameter :: dz !z方向の格子幅Delta_z


        
    !

    !global_variables
        !global変数：すべてのmoduleのsubroutineで参照可能な変数

        real(8),allocatable :: u(:)
        real(8),allocatable :: u_mid(:) !松野スキームにおける中間ステップ出力
        real(8),allocatable :: v(:)
        real(8),allocatable :: v_mid(:)
        real(8),allocatable :: pot_temp(:) !正規化された温位
        real(8),allocatable :: pot_temp_mid(:) 
        real(8),allocatable :: w(:)
        real(8),allocatable :: Phi(:) !ポテンシャルPhi
        real(8),allocatable :: theta(:) !緯度

    !

end module parameters_and_variables_for_simulation

program main
    use parameters_and_variables_for_simulation
    implicit none

end program main
