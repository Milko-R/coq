(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *         Copyright INRIA, CNRS and contributors             *)
(* <O___,, * (see version control and CREDITS file for authors & dates) *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

open Names

type locality = Discharge | Global of Declare.import_status

(** Declaration hooks *)
module Hook : sig
  type t

  (** Hooks allow users of the API to perform arbitrary actions at
     proof/definition saving time. For example, to register a constant
     as a Coercion, perform some cleanup, update the search database,
     etc...  *)
  module S : sig
    type t =
      { uctx : UState.t
      (** [ustate]: universe constraints obtained when the term was closed *)
      ; obls : (Id.t * Constr.t) list
      (** [(n1,t1),...(nm,tm)]: association list between obligation
          name and the corresponding defined term (might be a constant,
          but also an arbitrary term in the Expand case of obligations) *)
      ; scope : locality
      (** [scope]: Locality of the original declaration *)
      ; dref : GlobRef.t
      (** [dref]: identifier of the original declaration *)
      }
  end

  val make : (S.t -> unit) -> t
  val call : ?hook:t -> ?fix_exn:Future.fix_exn -> S.t -> unit
end

val declare_definition
  :  name:Id.t
  -> scope:locality
  -> kind:Decls.logical_kind
  -> ?hook_data:(Hook.t * UState.t * (Id.t * Constr.t) list)
  -> UnivNames.universe_binders
  -> Evd.side_effects Declare.proof_entry
  -> Impargs.manual_implicits
  -> GlobRef.t

val declare_assumption
  :  ?fix_exn:(Exninfo.iexn -> Exninfo.iexn)
  -> name:Id.t
  -> scope:locality
  -> hook:Hook.t option
  -> impargs:Impargs.manual_implicits
  -> uctx:UState.t
  -> Entries.parameter_entry
  -> GlobRef.t

val prepare_definition
  :  allow_evars:bool
  -> ?opaque:bool
  -> ?inline:bool
  -> poly:bool
  -> Evd.evar_map
  -> UState.universe_decl
  -> types:EConstr.t option
  -> body:EConstr.t
  -> Evd.evar_map * Evd.side_effects Declare.proof_entry

val prepare_parameter : allow_evars:bool ->
  poly:bool -> Evd.evar_map -> UState.universe_decl -> EConstr.types ->
  Evd.evar_map * Entries.parameter_entry
