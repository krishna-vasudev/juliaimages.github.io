# ---
# cover: assets/indexed_image.png
# title: Indexed image in 5 minutes
# author: Johnny Chen
# date: 2020-11-23
# ---

# This demonstration shows you how to work with [indexed
# image](https://en.wikipedia.org/wiki/Indexed_color) using
# [IndirectArrays.jl](https://github.com/JuliaArrays/IndirectArrays.jl)

# An indexed image consists of two parts: the indices and the palatte. The palatte keeps track of
# all possible pixel values of an image, while the `indices` consists of the palatte index of each
# pixel.

using Images

# The following is a normally used representation of image, i.e., an image as an array of
# `Colorant`s.

img = [
    RGB(0.0, 0.0, 0.0) RGB(1.0, 0.0, 0.0) RGB(0.0, 1.0, 0.0) RGB(0.0, 0.0, 1.0) RGB(1.0, 1.0, 1.0)
    RGB(1.0, 0.0, 0.0) RGB(0.0, 1.0, 0.0) RGB(0.0, 0.0, 1.0) RGB(1.0, 1.0, 1.0) RGB(0.0, 0.0, 0.0)
    RGB(0.0, 1.0, 0.0) RGB(0.0, 0.0, 1.0) RGB(1.0, 1.0, 1.0) RGB(0.0, 0.0, 0.0) RGB(1.0, 0.0, 0.0)
    RGB(0.0, 0.0, 1.0) RGB(1.0, 1.0, 1.0) RGB(0.0, 0.0, 0.0) RGB(1.0, 0.0, 0.0) RGB(0.0, 1.0, 0.0)
    RGB(1.0, 1.0, 1.0) RGB(0.0, 0.0, 0.0) RGB(1.0, 0.0, 0.0) RGB(0.0, 1.0, 0.0) RGB(0.0, 0.0, 1.0)]

# Alternatively, we could save it in the indexed image format:

indices = [1 2 3 4 5; 2 3 4 5 1; 3 4 5 1 2; 4 5 1 2 3; 5 1 2 3 4] # `i` records the pixel value `palatte[i]`
palatte = [RGB(0.0, 0.0, 0.0), RGB(1.0, 0.0, 0.0), RGB(0.0, 1.0, 0.0), RGB(0.0, 0.0, 1.0), RGB(1.0, 1.0, 1.0)]

palatte[indices] == img

# This is doable because it follows the Julia [indexing
# rules](https://docs.julialang.org/en/v1/manual/arrays/#man-supported-index-types) that `indices`
# is an array of scalar indices. For example, the following equivalence holds:

palatte[[1, 2]] == [palatte[1], palatte[2]]
palatte[[1 2; 2 1]] == [palatte[1] palatte[2]; palatte[2] palatte[1]]
#md nothing #hide

# Now, let's do some math on it. For this example, we are storing the data using type `Float64`,
# each `Float64` number requires 8 bytes (1 byte=8bits). Hence the normal representation format
# requires `5*5*3*8 = 600` bytes storage in total. As a comparison, we only need `5*5*8 + 5*3*8 =
# 320` bytes storage if we use the indexed image format. This is why indexed image requires less
# memories.
#
# Although it does compress the data in this example, in real world applications, it can be quite
# complicated on whether you should or should not use indexed image format. There are two main
# drawbacks of it:
#
# - indexed images can require more memories if `length(unique(img))` is too large.
# - indexing into an indexed image requires two `getindex` operations, so using it can be
#   theoratically slower than a normal image representation. This is a typical [space-time
#   tradeoff](https://en.wikipedia.org/wiki/Space%E2%80%93time_tradeoff) case.
#
# Benchmarks are always recommended before you choose to use the indexed image format.

# Using indexed image format with two seperate arrays can be inconvinient, hence
# [`IndirectArrays.jl`](https://github.com/JuliaArrays/IndirectArrays.jl) provides an array
# abstraction to union these two data:
using IndirectArrays

indexed_img = IndirectArray(indices, palatte)
img == indexed_img

# Under the hook, it is just a simple struct that subtypes `AbstractArray`:
# 
# ```julia
# # no need to run this
# struct IndirectArray{T,N,A,V} <: AbstractArray{T,N}
#     index::A
#     values::V
# end
# ```

indexed_img.index === indices, indexed_img.values === palatte

# Since `IndirectArray` is just an array, common image operations are applicable to this type, for
# example:

imresize(indexed_img; ratio=2) # no longer an IndirectArray

# --- save covers --- #src
save("assets/indexed_image.png", repeat(indexed_img, inner=(20, 20))) #src
