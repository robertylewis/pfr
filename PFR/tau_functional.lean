
import PFR.f2_vec
import PFR.ruzsa_distance
import PFR.ForMathlib.CompactProb
import PFR.ForMathlib.BorelSpace


/-!
# The tau functional

Definition of the tau functional and basic facts
-/

open MeasureTheory ProbabilityTheory
universe u


/-- For mathlib -/
lemma identDistrib_id {α β : Type*} [MeasurableSpace α] [MeasurableSpace β] {μ : Measure α}
    {X : α → β} (hX : AEMeasurable X μ) :
    IdentDistrib X id μ (μ.map X) where
  aemeasurable_fst := hX
  aemeasurable_snd := aemeasurable_id
  map_eq := by simp


variable (Ω₀₁ Ω₀₂ : Type*) [MeasureSpace Ω₀₁] [MeasureSpace Ω₀₂]
[IsProbabilityMeasure (ℙ : Measure Ω₀₁)] [IsProbabilityMeasure (ℙ : Measure Ω₀₂)]
variable (G : Type u) [AddCommGroup G] [ElementaryAddCommGroup G 2] [Fintype G] [MeasurableSpace G]

/-- A structure that packages all the fixed information in the main argument. In this way, when
defining the τ functional, we will only only need to refer to the package once in the notation
instead of stating the reference spaces, the reference measures and the reference random
variables. -/
structure refPackage :=
  X₀₁ : Ω₀₁ → G
  X₀₂ : Ω₀₂ → G
  hmeas1 : Measurable X₀₁
  hmeas2 : Measurable X₀₂


variable (p : refPackage Ω₀₁ Ω₀₂ G)
variable {Ω₀₁ Ω₀₂ G}

variable {Ω₁ Ω₂ Ω'₁ Ω'₂ : Type*}

noncomputable def η := (9:ℝ)⁻¹

/-- If $X_1,X_2$ are two $G$-valued random variables, then
$$  \tau[X_1; X_2] := d[X_1; X_2] + \eta  d[X^0_1; X_1] + \eta d[X^0_2; X_2].$$
Here, $X^0_1$ and $X^0_2$ are two random variables fixed once and for all in most of the argument.
To lighten notation, We package `X^0_1` and `X^0_2` in a single object named `p`.

We denote it as `τ[X₁ ; μ₁ # X₂ ; μ₂ | p]` where `p` is a fixed package containing the information
of the reference random variables. When the measurable spaces have a canonical measure `ℙ`, we
can use `τ[X₁ # X₂ | p]`
--/
@[pp_dot] noncomputable def tau {Ω₁ Ω₂ : Type*} [MeasurableSpace Ω₁] [MeasurableSpace Ω₂]
    (X₁ : Ω₁ → G) (X₂ : Ω₂ → G) (μ₁ : Measure Ω₁) (μ₂ : Measure Ω₂) : ℝ :=
  d[X₁ ; μ₁ # X₂ ; μ₂] + η * d[p.X₀₁ ; ℙ # X₁ ; μ₁] + η * d[p.X₀₂ ; ℙ # X₂ ; μ₂]

@[inherit_doc tau]
notation3:max "τ[" X₁ " ; " μ₁ " # " X₂ " ; " μ₂ " | " p"]" => tau p X₁ X₂ μ₁ μ₂

@[inherit_doc tau]
notation3:max "τ[" X₁ " # " X₂ " | " p"]" => tau p X₁ X₂ MeasureTheory.MeasureSpace.volume MeasureTheory.MeasureSpace.volume

lemma continuous_tau_restrict_probabilityMeasure
    [TopologicalSpace G] [DiscreteTopology G] [BorelSpace G] :
    Continuous
      (fun (μ : ProbabilityMeasure G × ProbabilityMeasure G) ↦ τ[id ; μ.1 # id ; μ.2 | p]) := by
  have obs₁ : Continuous
      (fun (μ : ProbabilityMeasure G × ProbabilityMeasure G) ↦ d[p.X₀₂ ; ℙ # id ; μ.2]) :=
    Continuous.comp (continuous_rdist_restrict_probabilityMeasure₁' _ _ p.hmeas2) continuous_snd
  have obs₂ : Continuous
      (fun (μ : ProbabilityMeasure G × ProbabilityMeasure G) ↦ d[id ; μ.1.toMeasure # id ; μ.2]) :=
    continuous_rdist_restrict_probabilityMeasure
  have obs₃ : Continuous
      (fun (μ : ProbabilityMeasure G × ProbabilityMeasure G) ↦ d[p.X₀₁ ; ℙ # id ; μ.1]) :=
    Continuous.comp (continuous_rdist_restrict_probabilityMeasure₁' _ _ p.hmeas1) continuous_fst
  continuity

/-- If $X'_1, X'_2$ are copies of $X_1,X_2$, then $\tau[X'_1;X'_2] = \tau[X_1;X_2]$. --/
lemma ProbabilityTheory.IdentDistrib.tau_eq [MeasurableSpace Ω₁] [MeasurableSpace Ω₂]
    [MeasurableSpace Ω'₁] [MeasurableSpace Ω'₂]
    {μ₁ : Measure Ω₁} {μ₂ : Measure Ω₂} {μ'₁ : Measure Ω'₁} {μ'₂ : Measure Ω'₂}
    {X₁ : Ω₁ → G} {X₂ : Ω₂ → G} {X'₁ : Ω'₁ → G} {X'₂ : Ω'₂ → G}
    (h₁ : IdentDistrib X₁ X'₁ μ₁ μ'₁) (h₂ : IdentDistrib X₂ X'₂ μ₂ μ'₂) :
    τ[X₁ ; μ₁ # X₂ ; μ₂ | p] = τ[X'₁ ; μ'₁ # X'₂ ; μ'₂ | p] := by
  simp only [tau]
  rw [(IdentDistrib.refl p.hmeas1.aemeasurable).rdist_eq h₁,
      (IdentDistrib.refl p.hmeas2.aemeasurable).rdist_eq h₂,
      h₁.rdist_eq h₂]

/-- Property recording the fact that two random variables minimize the tau functional. Expressed
in terms of measures on the group to avoid quantifying over all spaces, but this implies comparison
with any pair of random variables, see Lemma `is_tau_min`. -/
def tau_minimizes {Ω : Type*} [MeasureSpace Ω] (X₁ : Ω → G) (X₂ : Ω → G) : Prop :=
  ∀ (ν₁ : Measure G) (ν₂ : Measure G), IsProbabilityMeasure ν₁ → IsProbabilityMeasure ν₂ →
      τ[X₁ # X₂ | p] ≤ τ[id ; ν₁ # id ; ν₂ | p]

lemma tau_min_exists_measure [MeasurableSingletonClass G] :
    ∃ (μ : Measure G × Measure G),
    IsProbabilityMeasure μ.1 ∧ IsProbabilityMeasure μ.2 ∧
    ∀ (ν₁ : Measure G) (ν₂ : Measure G), IsProbabilityMeasure ν₁ → IsProbabilityMeasure ν₂ →
      τ[id ; μ.1 # id ; μ.2 | p] ≤ τ[id ; ν₁ # id ; ν₂ | p] := by
  let _i : TopologicalSpace G := (⊥ : TopologicalSpace G) -- Equip G with the discrete topology.
  have : DiscreteTopology G := ⟨rfl⟩
  have GG_cpt : CompactSpace (ProbabilityMeasure G × ProbabilityMeasure G) := inferInstance
  let T : ProbabilityMeasure G × ProbabilityMeasure G → ℝ := -- restrict τ to the compact subspace
    fun ⟨μ₁, μ₂⟩ ↦ τ[id ; μ₁ # id ; μ₂ | p]
  have T_cont : Continuous T := by apply continuous_tau_restrict_probabilityMeasure
  haveI : Inhabited G := ⟨0⟩ -- Need to record this for Lean to know that proba measures exist.
  obtain ⟨μ, ⟨_, hμ⟩⟩ := @IsCompact.exists_isMinOn ℝ (ProbabilityMeasure G × ProbabilityMeasure G)
                          _ _ _ _ Set.univ isCompact_univ ⟨default, trivial⟩ T T_cont.continuousOn
  use ⟨μ.1.toMeasure, μ.2.toMeasure⟩
  refine ⟨μ.1.prop, μ.2.prop, ?_⟩
  intro ν₁ ν₂ Pν₁ Pν₂
  rw [isMinOn_univ_iff] at hμ
  let ν : ProbabilityMeasure G × ProbabilityMeasure G := ⟨⟨ν₁, Pν₁⟩, ⟨ν₂, Pν₂⟩⟩
  exact hμ ν

lemma tau_minimizer_exists [MeasurableSingletonClass G] :
    ∃ (Ω : Type u) (mΩ : MeasureSpace Ω) (X₁ : Ω → G) (X₂ : Ω → G),
    Measurable X₁ ∧ Measurable X₂ ∧ IsProbabilityMeasure (ℙ : Measure Ω) ∧
    tau_minimizes p X₁ X₂ := by
  let μ := (tau_min_exists_measure p).choose
  have : IsProbabilityMeasure μ.1 := (tau_min_exists_measure p).choose_spec.1
  have : IsProbabilityMeasure μ.2 := (tau_min_exists_measure p).choose_spec.2.1
  have P : IsProbabilityMeasure (μ.1.prod μ.2) := by infer_instance
  let M : MeasureSpace (G × G) := ⟨μ.1.prod μ.2⟩
  refine ⟨G × G, M, Prod.fst, Prod.snd, measurable_fst, measurable_snd, P, ?_⟩
  intro ν₁ ν₂ h₁ h₂
  have A : τ[@Prod.fst G G # @Prod.snd G G | p] = τ[id ; μ.1 # id ; μ.2 | p] := by
    apply ProbabilityTheory.IdentDistrib.tau_eq
    · have : μ.1 = (μ.1.prod μ.2).map Prod.fst := by simp
      rw [this]
      exact identDistrib_id measurable_fst.aemeasurable
    · have : μ.2 = (μ.1.prod μ.2).map Prod.snd := by simp
      rw [this]
      exact identDistrib_id measurable_snd.aemeasurable
  convert (tau_min_exists_measure p).choose_spec.2.2 ν₁ ν₂ h₁ h₂


variable [MeasureSpace Ω] [hΩ₁ : MeasureSpace Ω'₁] [hΩ₂ : MeasureSpace Ω'₂]
  [IsProbabilityMeasure (ℙ : Measure Ω)]
  [IsProbabilityMeasure (ℙ : Measure Ω'₁)] [IsProbabilityMeasure (ℙ : Measure Ω'₂)]
  {X₁ : Ω → G} {X₂ : Ω → G} {X'₁ : Ω'₁ → G} {X'₂ : Ω'₂ → G}

lemma is_tau_min (h : tau_minimizes p X₁ X₂) (h1 : Measurable X'₁) (h2 : Measurable X'₂) :
    τ[X₁ # X₂ | p] ≤ τ[X'₁ # X'₂ | p] := by
  let ν₁ := (ℙ : Measure Ω'₁).map X'₁
  let ν₂ := (ℙ : Measure Ω'₂).map X'₂
  have B : τ[X'₁  # X'₂ | p] = τ[id ; ν₁ # id ; ν₂ | p] :=
    (identDistrib_id h1.aemeasurable).tau_eq p (identDistrib_id h2.aemeasurable)
  convert h ν₁ ν₂ (isProbabilityMeasure_map h1.aemeasurable)
    (isProbabilityMeasure_map h2.aemeasurable)

/-- Let `X₁` and `X₂` be tau-minimizers associated to `p`, with $d[X_1,X_2]=k$, then
$$ d[X'_1;X'_2] \geq k - \eta (d[X^0_1;X'_1] - d[X^0_1;X_1] ) - \eta (d[X^0_2;X'_2] - d[X^0_2;X_2] )$$
for any $G$-valued random variables $X'_1,X'_2$.
-/
lemma distance_ge_of_min (h : tau_minimizes p X₁ X₂) (h1 : Measurable X'₁) (h2 : Measurable X'₂) :
    d[X₁ # X₂] - η * (d[p.X₀₁ # X'₁] - d[p.X₀₁ # X₁]) - η * (d[p.X₀₂ # X'₂] - d[p.X₀₂ # X₂])
      ≤ d[X'₁ # X'₂] := by
  have Z := is_tau_min p h h1 h2
  simp [tau] at Z
  linarith

/-- Version of `distance_ge_of_min` with the measures made explicit. -/
lemma distance_ge_of_min' {Ω'₁ Ω'₂ : Type*} (h : tau_minimizes p X₁ X₂) [MeasurableSpace Ω'₁] [ MeasurableSpace Ω'₂] {μ: Measure Ω'₁} {μ' : Measure Ω'₂} [IsProbabilityMeasure μ] [IsProbabilityMeasure μ'] {X'₁: Ω'₁ → G} {X'₂: Ω'₂ → G} (h1 : Measurable X'₁) (h2 : Measurable X'₂) :
    d[X₁ # X₂] - η * (d[p.X₀₁; volume # X'₁; μ] - d[p.X₀₁ # X₁]) - η * (d[p.X₀₂; volume # X'₂; μ'] - d[p.X₀₂ # X₂])
      ≤ d[X'₁; μ # X'₂; μ'] := by
  set M1 : MeasureSpace Ω'₁ := { volume := μ }
  set M2 : MeasureSpace Ω'₂ := { volume := μ' }
  exact distance_ge_of_min p h h1 h2


open BigOperators

#check distance_ge_of_min
/--   For any $G$-valued random variables $X'_1,X'_2$ and random variables $Z,W$, one can lower bound $d[X'_1|Z;X'_2|W]$ by
$$k - \eta (d[X^0_1;X'_1|Z] - d[X^0_1;X_1] ) - \eta (d[X^0_2;X'_2|W] - d[X^0_2;X_2] ).$$
-/
lemma condDistance_ge_of_min
    [Fintype S] [MeasurableSpace S] [MeasurableSingletonClass S]
    [Fintype T] [MeasurableSpace T] [MeasurableSingletonClass T]
    (h : tau_minimizes p X₁ X₂)
    (h1 : Measurable X'₁) (h2 : Measurable X'₂) (Z : Ω'₁ → S) (W : Ω'₂ → T) (hZ : Measurable Z) (hW : Measurable W):
    d[X₁ # X₂] - η * (d[p.X₀₁ # X'₁ | Z] - d[p.X₀₁ # X₁])
      - η * (d[p.X₀₂ # X'₂ | W] - d[p.X₀₂ # X₂])
    ≤ d[X'₁ | Z # X'₂ | W] := by
      have hz (a : ℝ) : a = ∑ z : S, (ℙ (Z ⁻¹' {z})).toReal * a := by
        rw [<-Finset.sum_mul,sum_measure_preimage_singleton' ℙ hZ, one_mul]
      have hw (a : ℝ) : a = ∑ w : T, (ℙ (W ⁻¹' {w})).toReal * a := by
        rw [<-Finset.sum_mul,sum_measure_preimage_singleton' ℙ hW, one_mul]
      rw [cond_rdist_eq_sum h1 hZ h2 hW, cond_rdist'_eq_sum h1 hZ, hz d[X₁ # X₂], hz d[p.X₀₁ # X₁], hz (η * (d[p.X₀₂ # X'₂ | W] - d[p.X₀₂ # X₂])), <-Finset.sum_sub_distrib,Finset.mul_sum, <-Finset.sum_sub_distrib, <-Finset.sum_sub_distrib]
      apply Finset.sum_le_sum
      intro z _
      rw [cond_rdist'_eq_sum h2 hW, hw d[p.X₀₂ # X₂], hw ((ℙ (Z ⁻¹' {z})).toReal * d[X₁ # X₂] - η * ((ℙ (Z ⁻¹' {z})).toReal * d[p.X₀₁ ; ℙ # X'₁ ; ℙ[|Z ⁻¹' {z}]] - (ℙ (Z ⁻¹' {z})).toReal * d[p.X₀₁ # X₁])), <-Finset.sum_sub_distrib, Finset.mul_sum, Finset.mul_sum, <-Finset.sum_sub_distrib]
      apply Finset.sum_le_sum
      intro w _
      rcases eq_or_ne (ℙ (Z ⁻¹' {z})) 0 with hpz | hpz
      . simp [hpz]
      rcases eq_or_ne (ℙ (W ⁻¹' {w})) 0 with hpw | hpw
      . simp [hpw]
      set μ := (hΩ₁.volume)[|Z ⁻¹' {z}]
      have hμ : IsProbabilityMeasure μ :=  cond_isProbabilityMeasure ℙ hpz
      set μ' := ℙ[|W ⁻¹' {w}]
      have hμ' : IsProbabilityMeasure μ' :=  cond_isProbabilityMeasure ℙ hpw
      suffices : d[X₁ # X₂] - η * (d[p.X₀₁; volume # X'₁; μ] - d[p.X₀₁ # X₁]) - η * (d[p.X₀₂; volume # X'₂; μ'] - d[p.X₀₂ # X₂])
      ≤ d[X'₁ ; μ # X'₂; μ']
      . replace this := mul_le_mul_of_nonneg_left this (show 0 ≤ (ℙ (Z ⁻¹' {z})).toReal * (ℙ (W ⁻¹' {w})).toReal by positivity)
        convert this using 1
        ring
      exact distance_ge_of_min' p h h1 h2
