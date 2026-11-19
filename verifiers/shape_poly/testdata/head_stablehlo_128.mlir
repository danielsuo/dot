module @jit_model_fn attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main(%arg0: tensor<128x64xf32>, %arg1: tensor<64x64xf32>) -> (tensor<128x64xf32> {jax.result_info = "result"}) {
    %0 = stablehlo.sine %arg0 : tensor<128x64xf32>
    %1 = stablehlo.dot_general %0, %arg1, contracting_dims = [1] x [0], precision = [DEFAULT, DEFAULT] : (tensor<128x64xf32>, tensor<64x64xf32>) -> tensor<128x64xf32>
    return %1 : tensor<128x64xf32>
  }
}
