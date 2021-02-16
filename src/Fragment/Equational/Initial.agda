{-# OPTIONS --without-K --safe #-}

open import Fragment.Equational.Theory

module Fragment.Equational.Initial (Θ : Theory) where

open import Fragment.Equational.Model

open import Level using (Level; Setω)

private
  variable
    a ℓ₁ : Level

-- FIXME duplicates code in Fragment.Algebra.Initial

module _
  (M : Model Θ {a} {ℓ₁})
  where

  open Model M renaming (Carrierₐ to S)

  open import Fragment.Algebra.Homomorphism (Σ Θ)
  open import Fragment.Algebra.Homomorphism.Setoid (Σ Θ) using (_≡ₕ_)

  record IsInitial : Setω where
    field

      []_ : ∀ {b ℓ₂} (W : Model Θ {b} {ℓ₂})
            → S →ₕ Model.Carrierₐ W

      universal : ∀ {b ℓ₂} {W : Model Θ {b} {ℓ₂}}
                  → (F : S →ₕ Model.Carrierₐ W)
                  → F ≡ₕ [] W