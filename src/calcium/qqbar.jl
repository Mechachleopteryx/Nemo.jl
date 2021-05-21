###############################################################################
#
#   qqbar.jl : Calcium algebraic numbers in minimal polynomial representation
#
###############################################################################

export qqbar, CalciumQQBar, CalciumQQBarField, is_algebraic_integer, rand, abs2
export csgn, sign_real, sign_imag

###############################################################################
#
#   Data type and parent methods
#
###############################################################################

parent(a::qqbar) = CalciumQQBar

parent_type(::Type{qqbar}) = CalciumQQBarField

elem_type(::Type{CalciumQQBarField}) = qqbar

base_ring(a::CalciumQQBarField) = CalciumQQBar

base_ring(a::qqbar) = CalciumQQBar

isdomain_type(::Type{qqbar}) = true

###############################################################################
#
#   Hashing
#
###############################################################################

# todo
# function Base.hash(a::qqbar, h::UInt)
# end

###############################################################################
#
#   Constructors
#
###############################################################################

function qqbar(a::Int)
   z = qqbar()
   ccall((:qqbar_set_si, libcalcium), Nothing, (Ref{qqbar}, Int, ), z, a)
  return z
end

function qqbar(a::fmpz)
   z = qqbar()
   ccall((:qqbar_set_fmpz, libcalcium), Nothing, (Ref{qqbar}, Ref{fmpz}, ), z, a)
   return z
end

function qqbar(a::fmpq)
   z = qqbar()
   ccall((:qqbar_set_fmpq, libcalcium), Nothing, (Ref{qqbar}, Ref{fmpq}, ), z, a)
   return z
end


###############################################################################
#
#   Canonicalisation
#
###############################################################################

canonical_unit(a::qqbar) = a

###############################################################################
#
#   AbstractString I/O
#
###############################################################################

# todo
# function expressify(a::qqbar; context = nothing)::Any
# end

function native_string(x::qqbar)
   cstr = ccall((:qqbar_get_str_nd, libcalcium), Ptr{UInt8},
                (Ref{qqbar}, Int), x, Int(6))
   res = unsafe_string(cstr)
   ccall((:flint_free, libflint), Nothing,
         (Ptr{UInt8},),
         cstr)
   return res
end

function show(io::IO, F::CalciumQQBarField)
  print(io, "Field of Algebraic Numbers in minimal polynomial representation")
end

function show(io::IO, x::qqbar)
   print(io, native_string(x))
end

needs_parentheses(x::qqbar) = false

###############################################################################
#
#   Basic manipulation
#
###############################################################################

zero(a::CalciumQQBarField) = a(0)

one(a::CalciumQQBarField) = a(1)

function degree(x::qqbar)
   return ccall((:qqbar_degree, libcalcium), Int, (Ref{qqbar}, ), x)
end

function iszero(x::qqbar)
   return Bool(ccall((:qqbar_is_zero, libcalcium), Cint, (Ref{qqbar},), x))
end

function isone(x::qqbar)
   return Bool(ccall((:qqbar_is_one, libcalcium), Cint, (Ref{qqbar},), x))
end

function isinteger(x::qqbar)
   return Bool(ccall((:qqbar_is_integer, libcalcium), Cint, (Ref{qqbar},), x))
end

function isrational(x::qqbar)
   return Bool(ccall((:qqbar_is_rational, libcalcium), Cint, (Ref{qqbar},), x))
end

function isreal(x::qqbar)
   return Bool(ccall((:qqbar_is_real, libcalcium), Cint, (Ref{qqbar},), x))
end

function is_algebraic_integer(x::qqbar)
   return Bool(ccall((:qqbar_is_algebraic_integer, libcalcium), Cint, (Ref{qqbar},), x))
end

function minpoly(R::FmpzPolyRing, x::qqbar)
   z = R()
   ccall((:fmpz_poly_set, libflint), Nothing, (Ref{fmpz_poly}, Ref{qqbar}, ), z, x)
   return z
end

function minpoly(R::FmpqPolyRing, x::qqbar)
   z = R()
   ccall((:fmpq_poly_set_fmpz_poly, libflint), Nothing, (Ref{fmpq_poly}, Ref{qqbar}, ), z, x)
   return z
end

###############################################################################
#
#   Random generation
#
###############################################################################

function rand(R::CalciumQQBarField; degree::Int, bits::Int, randtype::Symbol=:null)
   state = _flint_rand_states[Threads.threadid()]
   x = R()

   degree <= 0 && error("degree must be positive")
   bits <= 0 && error("bits must be positive")

   if randtype == :null
      ccall((:qqbar_randtest, libcalcium), Nothing,
          (Ref{qqbar}, Ptr{Cvoid}, Int, Int), x, state.ptr, degree, bits)
   elseif randtype == :real
      ccall((:qqbar_randtest_real, libcalcium), Nothing,
          (Ref{qqbar}, Ptr{Cvoid}, Int, Int), x, state.ptr, degree, bits)
   elseif randtype == :nonreal
      degree < 2 && error("nonreal requires degree >= 2")
      ccall((:qqbar_randtest_nonreal, libcalcium), Nothing,
          (Ref{qqbar}, Ptr{Cvoid}, Int, Int), x, state.ptr, degree, bits)
   else
      error("randtype not defined")
   end

   return x
end

###############################################################################
#
#   Unary operators
#
###############################################################################

function -(a::qqbar)
   z = qqbar()
   ccall((:qqbar_neg, libcalcium), Nothing, (Ref{qqbar}, Ref{qqbar}), z, a)
   return z
end

###############################################################################
#
#   Binary operators
#
###############################################################################

function +(a::qqbar, b::qqbar)
   z = qqbar()
   ccall((:qqbar_add, libcalcium), Nothing,
         (Ref{qqbar}, Ref{qqbar}, Ref{qqbar}), z, a, b)
   return z
end

function -(a::qqbar, b::qqbar)
   z = qqbar()
   ccall((:qqbar_sub, libcalcium), Nothing,
         (Ref{qqbar}, Ref{qqbar}, Ref{qqbar}), z, a, b)
   return z
end

function *(a::qqbar, b::qqbar)
   z = qqbar()
   ccall((:qqbar_mul, libcalcium), Nothing,
         (Ref{qqbar}, Ref{qqbar}, Ref{qqbar}), z, a, b)
   return z
end

function ^(a::qqbar, b::qqbar)
   z = qqbar()
   ok = Bool(ccall((:qqbar_pow, libcalcium), Cint,
         (Ref{qqbar}, Ref{qqbar}, Ref{qqbar}), z, a, b))
   !ok && throw(DomainError((a, b)))
   return z
end

# todo: want qqbar_pow_fmpz, qqbar_pow_fmpq, qqbar_pow_si
^(a::qqbar, b::fmpz) = a ^ qqbar(b)
^(a::qqbar, b::fmpq) = a ^ qqbar(b)
^(a::qqbar, b::Int) = a ^ qqbar(b)

###############################################################################
#
#   Exact division
#
###############################################################################

function divexact(a::qqbar, b::qqbar)
   iszero(b) && throw(DivideError())
   z = qqbar()
   ccall((:qqbar_div, libcalcium), Nothing,
         (Ref{qqbar}, Ref{qqbar}, Ref{qqbar}), z, a, b)
   return z
end

div(a::qqbar, b::qqbar) = divexact(a, b)

function <<(a::qqbar, b::Int)
   z = qqbar()
   ccall((:qqbar_mul_2exp_si, libcalcium), Nothing,
         (Ref{qqbar}, Ref{qqbar}, Int), z, a, b)
   return z
end

function >>(a::qqbar, b::Int)
   z = qqbar()
   ccall((:qqbar_mul_2exp_si, libcalcium), Nothing,
         (Ref{qqbar}, Ref{qqbar}, Int), z, a, -b)
   return z
end


###############################################################################
#
#   Comparison
#
###############################################################################

function ==(a::qqbar, b::qqbar)
   return Bool(ccall((:qqbar_equal, libcalcium), Cint,
                (Ref{qqbar}, Ref{qqbar}), a, b))
end

function cmp(a::qqbar, b::qqbar)
   !isreal(a) && throw(DomainError(a, "comparing nonreal numbers"))
   !isreal(b) && throw(DomainError(b, "comparing nonreal numbers"))
   return ccall((:qqbar_cmp_re, libcalcium), Cint,
                (Ref{qqbar}, Ref{qqbar}), a, b)
end

function isless(a::qqbar, b::qqbar)
    return cmp(a, b) < 0
end

# todo: name and export the following functions?

function cmp_real(a::qqbar, b::qqbar)
   return ccall((:qqbar_cmp_re, libcalcium), Cint,
                (Ref{qqbar}, Ref{qqbar}), a, b)
end

function cmp_imag(a::qqbar, b::qqbar)
   return ccall((:qqbar_cmp_im, libcalcium), Cint,
                (Ref{qqbar}, Ref{qqbar}), a, b)
end

function cmpabs_real(a::qqbar, b::qqbar)
   return ccall((:qqbar_cmpabs_re, libcalcium), Cint,
                (Ref{qqbar}, Ref{qqbar}), a, b)
end

function cmpabs_imag(a::qqbar, b::qqbar)
   return ccall((:qqbar_cmpabs_im, libcalcium), Cint,
                (Ref{qqbar}, Ref{qqbar}), a, b)
end

function cmp_root_order(a::qqbar, b::qqbar)
   return ccall((:qqbar_cmp_root_order, libcalcium), Cint,
                (Ref{qqbar}, Ref{qqbar}), a, b)
end

function isless_root_order(a::qqbar, b::qqbar)
    return cmp_root_order(a, b) < 0
end

# todo: wrap qqbar_equal_fmpq_poly_val

###############################################################################
#
#   Complex parts
#
###############################################################################

function real(a::qqbar)
   z = qqbar()
   ccall((:qqbar_re, libcalcium), Nothing, (Ref{qqbar}, Ref{qqbar}), z, a)
   return z
end

function imag(a::qqbar)
   z = qqbar()
   ccall((:qqbar_im, libcalcium), Nothing, (Ref{qqbar}, Ref{qqbar}), z, a)
   return z
end

function abs(a::qqbar)
   z = qqbar()
   ccall((:qqbar_abs, libcalcium), Nothing, (Ref{qqbar}, Ref{qqbar}), z, a)
   return z
end

function conj(a::qqbar)
   z = qqbar()
   ccall((:qqbar_conj, libcalcium), Nothing, (Ref{qqbar}, Ref{qqbar}), z, a)
   return z
end

function abs2(a::qqbar)
   z = qqbar()
   ccall((:qqbar_abs2, libcalcium), Nothing, (Ref{qqbar}, Ref{qqbar}), z, a)
   return z
end

function sign(a::qqbar)
   z = qqbar()
   ccall((:qqbar_sgn, libcalcium), Nothing, (Ref{qqbar}, Ref{qqbar}), z, a)
   return z
end

function csgn(a::qqbar)
   return qqbar(Int(ccall((:qqbar_csgn, libcalcium), Cint, (Ref{qqbar}, ), a)))
end

function sign_real(a::qqbar)
   return qqbar(Int(ccall((:qqbar_sgn_re, libcalcium), Cint, (Ref{qqbar}, ), a)))
end

function sign_imag(a::qqbar)
   return qqbar(Int(ccall((:qqbar_sgn_im, libcalcium), Cint, (Ref{qqbar}, ), a)))
end

function floor(a::qqbar)
   z = fmpz()
   ccall((:qqbar_floor, libcalcium), Nothing, (Ref{fmpz}, Ref{qqbar}, ), z, a)
   return qqbar(z)
end

function ceil(a::qqbar)
   z = fmpz()
   ccall((:qqbar_ceil, libcalcium), Nothing, (Ref{fmpz}, Ref{qqbar}, ), z, a)
   return qqbar(z)
end


###############################################################################
#
#   Roots
#
###############################################################################

function sqrt(a::qqbar)
   z = qqbar()
   ccall((:qqbar_sqrt, libcalcium), Nothing, (Ref{qqbar}, Ref{qqbar}), z, a)
   return z
end

function root(a::qqbar, n::Int)
   n <= 0 && throw(DomainError(n))
   z = qqbar()
   ccall((:qqbar_root_ui, libcalcium), Nothing, (Ref{qqbar}, Ref{qqbar}, UInt), z, a, n)
   return z
end

function root_of_unity(C::CalciumQQBarField, n::Int)
   n <= 0 && throw(DomainError(n))
   z = qqbar()
   ccall((:qqbar_root_of_unity, libcalcium), Nothing, (Ref{qqbar}, Int, UInt), z, 1, n)
   return z
end

function root_of_unity(C::CalciumQQBarField, n::Int, k::Int)
   n <= 0 && throw(DomainError(n))
   z = qqbar()
   ccall((:qqbar_root_of_unity, libcalcium), Nothing, (Ref{qqbar}, Int, UInt), z, k, n)
   return z
end

function qqbar_vec(n::Int)
   return ccall((:_qqbar_vec_init, libcalcium), Ptr{qqbar_struct}, (Int,), n)
end

function array(R::CalciumQQBarField, v::Ptr{qqbar_struct}, n::Int)
   r = Vector{qqbar}(undef, n)
   for i=1:n
       r[i] = R()
       ccall((:qqbar_set, libcalcium), Nothing, (Ref{qqbar}, Ptr{qqbar_struct}),
           r[i], v + (i-1)*sizeof(qqbar_struct))
   end
   return r
end

function qqbar_vec_clear(v::Ptr{qqbar_struct}, n::Int)
   ccall((:_qqbar_vec_clear, libcalcium), Nothing, (Ptr{qqbar_struct}, Int), v, n)
end

function roots(f::fmpz_poly, R::CalciumQQBarField)
    deg = degree(f)

    if deg <= 0
        return Array{qqbar}(undef, 0)
    end

    roots = qqbar_vec(deg)
    ccall((:qqbar_roots_fmpz_poly, libcalcium), Nothing, (Ptr{qqbar_struct}, Ref{fmpz_poly}, Int), roots, f, 0)

    res = array(R, roots, deg)
    qqbar_vec_clear(roots, deg)
    return res
end

# todo: move this
function _numerator(a::fmpq_poly)
   z = fmpz_poly()
   ccall((:fmpq_poly_get_numerator, libflint), Nothing,
         (Ref{fmpz_poly}, Ref{fmpq_poly}), z, a)
   return z
end

function roots(f::fmpq_poly, R::CalciumQQBarField)
    return roots(_numerator(f), R)
end

###############################################################################
#
#   Unsafe functions
#
###############################################################################

function zero!(z::qqbar)
   ccall((:qqbar_zero, libcalcium), Nothing, (Ref{qqbar},), z)
   return z
end

function mul!(z::qqbar, x::qqbar, y::qqbar)
   ccall((:qqbar_mul, libcalcium), Nothing,
                (Ref{qqbar}, Ref{qqbar}, Ref{qqbar}), z, x, y)
   return z
end

function addeq!(z::qqbar, x::qqbar)
   ccall((:qqbar_add, libcalcium), Nothing,
                (Ref{qqbar}, Ref{qqbar}, Ref{qqbar}), z, z, x)
   return z
end

function add!(z::qqbar, x::qqbar, y::qqbar)
   ccall((:qqbar_add, libcalcium), Nothing,
                (Ref{qqbar}, Ref{qqbar}, Ref{qqbar}), z, x, y)
   return z
end

###############################################################################
#
#   Parent object call overloads
#
###############################################################################

(a::CalciumQQBarField)() = qqbar()

(a::CalciumQQBarField)(b::Int) = qqbar(b)

(a::CalciumQQBarField)(b::fmpz) = qqbar(b)

(a::CalciumQQBarField)(b::fmpq) = qqbar(b)

(a::CalciumQQBarField)(b::qqbar) = b

