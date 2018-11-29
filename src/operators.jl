

struct DiracDelta{T,A} <: AbstractQuasiVector{T}
    x::T
    axis::A
end

DiracDelta{T}(x, axis::A) where {T,A} = DiracDelta{T,A}(x, axis)
DiracDelta(axis) = DiracDelta(zero(float(eltype(axis))), axis)

axes(δ::DiracDelta) = (δ.axis,)
IndexStyle(::Type{<:DiracDelta}) = IndexLinear()

==(a::DiracDelta, b::DiracDelta) = a.axis == b.axis && a.x == b.x

function getindex(δ::DiracDelta{T}, x::Real) where T
    x ∈ δ.axis || throw(BoundsError())
    x == δ.x ? inv(zero(T)) : zero(T)
end


function materialize(M::Mul2{<:Any,<:Any,<:QuasiAdjoint{<:Any,<:DiracDelta},<:AbstractQuasiVector})
    A, B = M.factors
    axes(A,2) == axes(B,1) || throw(DimensionMismatch())
    B[parent(A).x]
end

function materialize(M::Mul2{<:Any,<:Any,<:QuasiAdjoint{<:Any,<:DiracDelta},<:AbstractQuasiMatrix})
    A, B = M.factors
    axes(A,2) == axes(B,1) || throw(DimensionMismatch())
    B[parent(A).x,:]
end

struct Derivative{T,A} <: AbstractQuasiMatrix{T}
    axis::A
end

Derivative{T}(axis::A) where {T,A} = Derivative{T,A}(axis)
Derivative(axis) = Derivative{Float64}(axis)

axes(D::Derivative) = (D.axis, D.axis)
==(a::Derivative, b::Derivative) = a.axis == b.axis


function materialize(M::Mul2{<:Any,<:Any,<:Derivative,<:SubQuasiArray})
    A, B = M.factors
    axes(A,2) == axes(B,1) || throw(DimensionMismatch())
    P = parent(B)
    (Derivative(axes(P,1))*P)[parentindices(B)...]
end


materialize(M::Mul2{<:Any,<:Any,<:Derivative}) = MulQuasiArray(M)
materialize(M::Mul2{<:Any,<:Any,<:Any,<:Derivative}) = MulQuasiArray(M)
