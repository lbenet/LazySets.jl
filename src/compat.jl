#=
This file defines internal functions for compatibility across
different Julia versions.
=#

using Compat
using Compat: copyto!, axes, argmax, @warn
import Compat.String
using Compat.LinearAlgebra
import Compat.LinearAlgebra: norm, checksquare, LAPACKException,
                             SingularException, ×, cond
import Compat.InteractiveUtils.subtypes
export _At_mul_B

@static if VERSION < v"0.7-"
    using Compat.Random
    import Compat.Random: GLOBAL_RNG
    @inline function _At_mul_B(A, B)
        return At_mul_B(A, B)
    end
    expmat = expm
else
    using SparseArrays
    using Random
    using Random: GLOBAL_RNG, SamplerType
    @inline function _At_mul_B(A, B)
        return transpose(A) * B
    end
    expmat = exp
end
