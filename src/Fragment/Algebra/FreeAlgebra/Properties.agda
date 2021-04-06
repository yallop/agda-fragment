{-# OPTIONS --without-K --safe #-}

module Fragment.Algebra.FreeAlgebra.Properties where

open import Fragment.Algebra.FreeAlgebra.Base
open import Fragment.Algebra.FreeAlgebra.Definitions
open import Fragment.Algebra.Algebra
open import Fragment.Algebra.Signature renaming (_⦉_⦊ to _⦉_⦊ₜ)

open import Level using (Level; _⊔_)
open import Function using (_$_)

open import Data.Fin using (Fin)
open import Data.Nat using (ℕ)
open import Data.Sum using (inj₁; inj₂)

open import Relation.Binary using (IsEquivalence)
open import Relation.Binary.PropositionalEquality as PE using (_≡_)

import Data.Vec.Relation.Binary.Pointwise.Inductive as PW
open import Data.Vec using (Vec; []; _∷_; map)

private
  variable
    a b ℓ₁ ℓ₂ : Level

module _ {Σ n}
  (S : Algebra Σ {a} {ℓ₁})
  (θ : Environment n S)
  where

  open Algebra S renaming (Carrier to A)

  open import Fragment.Algebra.Homomorphism Σ
  open import Fragment.Algebra.Homomorphism.Setoid Σ using (_≡ₕ_)
  open import Fragment.Algebra.TermAlgebra (Σ ⦉ n ⦊ₜ) using (Expr; term)

  open import Relation.Binary.Reasoning.Setoid Carrierₛ
  open import Data.Vec.Relation.Binary.Equality.Setoid Carrierₛ

  Substitution : (Expr → A) → Set a
  Substitution f = ∀ {k : Fin n}
                   → f (term₂ k) ≡ θ k

  Substitutionₕ : (|T| Σ ⦉ n ⦊) →ₕ S → Set a
  Substitutionₕ H = Substitution (_→ₕ_.h H)

  mutual
    subst-args : ∀ {arity} → Vec Expr arity → Vec A arity
    subst-args []       = []
    subst-args (x ∷ xs) = (subst x) ∷ (subst-args xs)

    subst : Expr → A
    subst (term₂ k) = θ k
    subst (term₁ f) = ⟦ f ⟧ []
    subst (term f (x ∷ xs))  = ⟦ f ⟧ (subst-args (x ∷ xs))

  subst-args≡map : ∀ {arity} {xs : Vec Expr arity}
                   → map subst xs ≡ subst-args xs
  subst-args≡map {_} {[]}     = PE.refl
  subst-args≡map {_} {x ∷ xs} = PE.cong (subst x ∷_) (subst-args≡map {_} {xs})

  subst-cong : Congruent _≡_ _≈_ subst
  subst-cong x≡y = reflexive (PE.cong subst x≡y)

  subst-hom : Homomorphic (|T| Σ ⦉ n ⦊) S subst
  subst-hom {_} f []       = refl
  subst-hom {m} f (x ∷ xs) =
    ⟦⟧-cong f $
      IsEquivalence.reflexive
        (≋-isEquivalence m)
        (subst-args≡map {_} {x ∷ xs})

  substₕ : (|T| Σ ⦉ n ⦊) →ₕ S
  substₕ = record { h      = subst
                  ; h-cong = subst-cong
                  ; h-hom  = subst-hom
                  }

  substitution-subst : Substitution subst
  substitution-subst = PE.refl

  substitutionₕ-substₕ : Substitutionₕ substₕ
  substitutionₕ-substₕ = substitution-subst

  mutual
    subst-args-universal : (H : (|T| Σ ⦉ n ⦊) →ₕ S)
                           → Substitutionₕ H
                           → ∀ {arity} {xs : Vec Expr arity}
                           → map (_→ₕ_.h H) xs ≋ subst-args xs
    subst-args-universal H _       {_} {[]}     = PW.[]
    subst-args-universal H h-subst {_} {x ∷ xs} =
      PW._∷_
        (substₕ-universal H h-subst {x})
        (subst-args-universal H h-subst {_} {xs})

    substₕ-universal : (H : (|T| Σ ⦉ n ⦊) →ₕ S)
                       → Substitutionₕ H
                       → H ≡ₕ substₕ
    substₕ-universal H h-subst {term₂ k} = reflexive (h-subst {k})
    substₕ-universal H _       {term₁ f} = sym (h-hom f [])
      where open _→ₕ_ H
    substₕ-universal H h-subst {term f (x ∷ xs)}  = begin
        h (term f (x ∷ xs))
      ≈⟨ sym (h-hom f (x ∷ xs)) ⟩
        ⟦ f ⟧ (map h (x ∷ xs))
      ≈⟨ ⟦⟧-cong f (subst-args-universal H h-subst) ⟩
        ⟦ f ⟧ (subst-args (x ∷ xs))
      ≡⟨⟩
        subst (term f (x ∷ xs))
      ∎
      where open _→ₕ_ H

module _ {Σ n}
  {S : Algebra Σ {a} {ℓ₁}}
  where

  open Algebra S renaming (Carrier to A)

  open import Function using (_∘_)

  open import Fragment.Algebra.Homomorphism Σ
  open import Fragment.Algebra.Homomorphism.Setoid Σ
  open import Fragment.Algebra.TermAlgebra Σ hiding (Expr)
  open import Fragment.Algebra.TermAlgebra (Σ ⦉ n ⦊ₜ) using (Expr)

  open import Relation.Binary.Reasoning.Setoid Carrierₛ
  open import Data.Vec.Relation.Binary.Equality.Setoid Carrierₛ using (_≋_)
  open import Data.Vec.Relation.Binary.Pointwise.Inductive as PW using ([]; _∷_)

  mutual
    subst-eval-args : ∀ {arity}
                      → {θ : Environment n |T|}
                      → {xs : Vec Expr arity}
                      → eval-args S (subst-args |T| θ xs)
                        ≋ subst-args S (eval S ∘ θ) xs
    subst-eval-args {θ = _} {xs = []}     = []
    subst-eval-args {θ = θ} {xs = x ∷ xs} = (subst-eval {θ} {x}) ∷ subst-eval-args

    subst-eval : ∀ {θ : Environment n |T|}
                 → evalₕ S ∘ₕ (substₕ |T| θ) ≡ₕ substₕ S (eval S ∘ θ)
    subst-eval {x = term₂ k} = refl
    subst-eval {x = term₁ f} = refl
    subst-eval {x = term f (x ∷ xs)}  = ⟦⟧-cong f (subst-eval-args {xs = x ∷ xs})

  mutual
    subst-subst-args : ∀ {m arity}
                       → {θ : Environment m S}
                       → {θ' : Environment n |T| Σ ⦉ m ⦊}
                       → {xs : Vec Expr arity}
                       → subst-args S θ (subst-args |T| Σ ⦉ m ⦊ θ' xs)
                         ≋  subst-args S ((subst S θ) ∘ θ') xs
    subst-subst-args {xs = []} = []
    subst-subst-args {xs = x ∷ xs} = subst-subst {x = x} ∷ subst-subst-args

    subst-subst : ∀ {m}
                  → {θ : Environment m S}
                  → {θ' : Environment n |T| Σ ⦉ m ⦊}
                  → (substₕ S θ) ∘ₕ (substₕ |T| Σ ⦉ m ⦊ θ') ≡ₕ substₕ S ((subst S θ) ∘ θ')
    subst-subst {x = term₂ k} = refl
    subst-subst {x = term₁ f} = refl
    subst-subst {x = term f (x ∷ xs)} = ⟦⟧-cong f (subst-subst-args {xs = x ∷ xs})
