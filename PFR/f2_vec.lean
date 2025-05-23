import Mathlib.Data.Finset.Pointwise
import Mathlib.GroupTheory.OrderOfElement
import Mathlib.Tactic

/-!
# Finite field vector spaces

Here we define the notion of a vector space over a finite field, and record basic results about it.

## Main classes

* `ElementaryAddCommGroup`: An elementary p-group.

-/


open Pointwise Nat

class ElementaryAddCommGroup (G : Type*) [AddCommGroup G] (p : outParam ℕ) where
  orderOf_of_ne {x : G} (hx : x ≠ 0) : addOrderOf x = p
-- may want to change this to p . x = 0 for all x

variable [AddCommGroup G] [elem : ElementaryAddCommGroup G 2]

@[simp]
lemma sub_eq_add ( x y : G ) : x - y = x + y := by
  rw [sub_eq_add_neg, add_right_inj, ← add_eq_zero_iff_neg_eq]
  by_cases h : y = 0
  · simp only [h, add_zero]
  · simpa only [elem.orderOf_of_ne h, two_nsmul] using (addOrderOf_nsmul_eq_zero y)

@[simp]
lemma pi.sub_eq_add {ι} ( x y : ι → G ) : x - y = x + y := by ext; simp

@[simp]
lemma add_self ( x : G ) : x + x = 0 := by
  rw [← sub_eq_add]
  simp

lemma sum_add_sum_eq_sum ( x y z : G ) : (x + y) + (y + z) = x + z := by
  rw [← sub_eq_add x y]
  abel

lemma sum_add_sum_add_sum_eq_zero ( x y z : G ) : (x + y) + (y + z) + (z + x) = 0 := by
  rw [sum_add_sum_eq_sum, add_comm x z, add_self]
