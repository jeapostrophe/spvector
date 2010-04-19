#lang scribble/doc
@(require (planet cce/scheme:4:1/planet)
          scribble/manual
          (for-label scheme/base
                     scheme/contract
                     "main.ss"))

@title{Semi-persistent Vectors}
@author{@(author+email "Jay McCarthy" "jay@plt-scheme.org")}

@defmodule/this-package[]

This package defines @deftech{semi-persistent vectors}. These vectors are persistent, because old versions are maintained. 
However, performance degrades when old versions are used. Each operation is O(@scheme[1]) if the newest version is used, otherwise each
operation is O(@scheme[n]) where @scheme[n] is the number of versions to the current.

@defproc[(spvector? [v any/c])
         boolean?]{
 Determines if @scheme[v] is a @tech{semi-persistent vector}.
}
                  
@defproc[(build-spvector [n exact-positive-integer?]
                         [f (exact-nonnegative-integer? . -> . any/c)])
         spvector?]{
 Like @scheme[build-vector], but builds a @tech{semi-persistent vector}.
}
                   
@defproc[(make-spvector [e any/c] ...)
         spvector?]{
 Like @scheme[vector], but builds a @tech{semi-persistent vector}.
}
                   
@defproc[(spvector-length [vec spvector?])
         exact-positive-integer?]{
 Returns the length of @scheme[vec].
}
                                 
@defproc[(spvector-ref [vec spvector?] [i exact-nonnegative-integer?])
         any/c]{
 Returns the value at @scheme[i] of @scheme[vec], if it is a valid reference.
}
               
@defproc[(spvector-set [vec spvector?] [i exact-nonnegative-integer?] [v any/c])
         spvector?]{
 Returns a new @tech{semi-persistent vector} where @scheme[(spvector-ref _new-vec i)] returns @scheme[v].
}
                   
@defproc[(spvector-set! [vec spvector?] [i exact-nonnegative-integer?] [v any/c])
         void]{
 Destructively modifies @scheme[vec], like @scheme[vector-set!].
}
              
@section{Implementation notes}

@tech{Semi-persistent vectors} may be used as @tech[#:doc '(lib "scribblings/reference/reference.scrbl")]{sequences}.

@tech{Semi-persistent vectors} are implemented using a weak hash table to log undo information for modifications.
These are indexed by uninterned symbols that are stored in the @scheme[spvector?] struct. This means that the garbage collector
reclaims space in the log when the old version symbols are no longer reachable. Thus, if you use this structure in a purely linear
way, it will behavior exactly like normal vectors asymptotically.