module @jit_call attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main(%arg0: tensor<128x64xf32>, %arg1: tensor<64x64xf32>) -> (tensor<128x64xf32> {jax.result_info = "result"}) {
    %0 = stablehlo.convert %arg0 : (tensor<128x64xf32>) -> tensor<?x64xf32>
    %1 = call @call_exported_model_fn(%0, %arg1) : (tensor<?x64xf32>, tensor<64x64xf32>) -> tensor<?x64xf32>
    %2 = stablehlo.convert %1 : (tensor<?x64xf32>) -> tensor<128x64xf32>
    return %2 : tensor<128x64xf32>
  }
  func.func private @call_exported_model_fn(%arg0: tensor<?x64xf32>, %arg1: tensor<64x64xf32>) -> (tensor<?x64xf32> {jax.result_info = "result"}) {
    %c = stablehlo.constant dense<0> : tensor<i32>
    %c_0 = stablehlo.constant dense<-1> : tensor<i32>
    %c_1 = stablehlo.constant dense<1> : tensor<i32>
    %0 = stablehlo.get_dimension_size %arg0, dim = 0 : (tensor<?x64xf32>) -> tensor<i32>
    %1 = stablehlo.compare GE, %0, %c_1, SIGNED : (tensor<i32>, tensor<i32>) -> tensor<i1>
    stablehlo.custom_call @shape_assertion(%1, %0) {api_version = 2 : i32, error_message = "Input shapes do not match the polymorphic shapes specification. Expected value >= 1 for dimension variable 's'. Using the following polymorphic shapes specifications: args[0].shape = (s, 64). Obtained dimension variables: 's' = {0} from specification 's' for dimension args[0].shape[0] (= {0}), . Please see https://docs.jax.dev/en/latest/501/shape-polymorphism.html#shape-assertion-errors for more details.", has_side_effect = true} : (tensor<i1>, tensor<i32>) -> ()
    %2 = stablehlo.convert %0 : tensor<i32>
    %3 = stablehlo.add %2, %c_0 : tensor<i32>
    %4 = stablehlo.compare GE, %3, %c, SIGNED : (tensor<i32>, tensor<i32>) -> tensor<i1>
    %5 = stablehlo.convert %0 : tensor<i32>
    %6 = stablehlo.add %5, %c_0 : tensor<i32>
    stablehlo.custom_call @shape_assertion(%4, %6, %0) {api_version = 2 : i32, error_message = "Input shapes do not match the symbolic shape constraint s >= 1. Expected 's - 1' to be greater or equal to 0, but found {0}.  Using the following polymorphic shapes specifications: args[0].shape = (s, 64). Obtained dimension variables: 's' = {1} from specification 's' for dimension args[0].shape[0] (= {1}), . Please see https://docs.jax.dev/en/latest/501/shape-polymorphism.html#shape-assertion-errors for more details.", has_side_effect = true} : (tensor<i1>, tensor<i32>, tensor<i32>) -> ()
    %7 = call @_wrapped_jax_export_main(%0, %arg0, %arg1) : (tensor<i32>, tensor<?x64xf32>, tensor<64x64xf32>) -> tensor<?x64xf32>
    return %7 : tensor<?x64xf32>
  }
  func.func private @_wrapped_jax_export_main(%arg0: tensor<i32> {jax.global_constant = "s"}, %arg1: tensor<?x64xf32>, %arg2: tensor<64x64xf32>) -> (tensor<?x64xf32> {jax.result_info = "result"}) {
    %0 = stablehlo.sine %arg1 : tensor<?x64xf32>
    %1 = stablehlo.dot_general %0, %arg2, contracting_dims = [1] x [0] : (tensor<?x64xf32>, tensor<64x64xf32>) -> tensor<?x64xf32>
    return %1 : tensor<?x64xf32>
  }
}
