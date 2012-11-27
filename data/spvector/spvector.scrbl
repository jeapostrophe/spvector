#lang scribble/doc
@(require scribble/manual
          (for-label racket/base
                     racket/contract
                     data/spvector))

@title{Semi-persistent Vectors}
@author{@(author+email "Jay McCarthy" "jay@racket-lang.org")}

@defmodule[data/spvector]

This package defines @deftech{semi-persistent vectors}. These vectors are persistent, because old versions are maintained. 
However, performance degrades when old versions are used. Each operation is O(@racket[1]) if the newest version is used, otherwise each
operation is O(@racket[n]) where @racket[n] is the number of versions to the current.

@defproc[(spvector? [v any/c])
         boolean?]{
 Determines if @racket[v] is a @tech{semi-persistent vector}.
}
                  
@defproc[(build-spvector [n exact-positive-integer?]
                         [f (exact-nonnegative-integer? . -> . any/c)])
         spvector?]{
 Like @racket[build-vector], but builds a @tech{semi-persistent vector}.
}
                   
@defproc[(make-spvector [e any/c] ...)
         spvector?]{
 Like @racket[vector], but builds a @tech{semi-persistent vector}.
}
                   
@defproc[(spvector-length [vec spvector?])
         exact-positive-integer?]{
 Returns the length of @racket[vec].
}
                                 
@defproc[(spvector-ref [vec spvector?] [i exact-nonnegative-integer?])
         any/c]{
 Returns the value at @racket[i] of @racket[vec], if it is a valid reference.
}
               
@defproc[(spvector-set [vec spvector?] [i exact-nonnegative-integer?] [v any/c])
         spvector?]{
 Returns a new @tech{semi-persistent vector} where @racket[(spvector-ref _new-vec i)] returns @racket[v].
}
                   
@defproc[(spvector-set! [vec spvector?] [i exact-nonnegative-integer?] [v any/c])
         void]{
 Destructively modifies @racket[vec], like @racket[vector-set!].
}
              
@section{Implementation notes}

@tech{Semi-persistent vectors} may be used as @tech[#:doc '(lib "scribblings/reference/reference.scrbl")]{sequences}.

@tech{Semi-persistent vectors} are implemented using a weak hash table to log undo information for modifications.
These are indexed by uninterned symbols that are stored in the @racket[spvector?] struct. This means that the garbage collector
reclaims space in the log when the old version symbols are no longer reachable. Thus, if you use this structure in a purely linear
way, it will behavior exactly like normal vectors asymptotically.
