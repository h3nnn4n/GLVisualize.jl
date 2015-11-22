typealias ArrayOrSignal{T, N} Union{Array{T, N}, Signal{Array{T, N}}}
typealias VecOrSignal{T} 	ArrayOrSignal{T, 1}
typealias MatOrSignal{T} 	ArrayOrSignal{T, 2}
typealias VolumeOrSignal{T} ArrayOrSignal{T, 3}

typealias ArrayTypes{T, N} Union{GPUArray{T, N}, ArrayOrSignal{T,N}}
typealias VecTypes{T} 		ArrayTypes{T, 1}
typealias MatTypes{T} 		ArrayTypes{T, 2}
typealias VolumeTypes{T} 	ArrayTypes{T, 3}

@enum Shape CIRCLE RECTANGLE ROUNDED_RECTANGLE DISTANCEFIELD TRIANGLE

immutable Grid{N, T <: Range}
    dims::NTuple{N, T}
end
Grid(ranges::Range...) = Grid(ranges)
Base.length(p::Grid) = mapreduce(+, length, p.dims)

immutable Intensity{N, T} <: FixedVector{N, T}
	_::NTuple{N, T}
end
export Intensity