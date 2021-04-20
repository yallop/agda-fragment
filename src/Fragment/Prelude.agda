{-# OPTIONS --without-K --safe #-}

module Fragment.Prelude where

open import Fragment.Macros.Fragment public

open import Fragment.Equational.Theory.Bundles public
open import Fragment.Equational.Structures public
open import Fragment.Equational.FreeExtension
  using (FreeExtension; frexify) public

open import Fragment.Extensions.Semigroup using (SemigroupFrex) public
