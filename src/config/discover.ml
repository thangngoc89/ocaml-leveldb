module C = Configurator.V1

(* Backported from OCaml 4.10.0 *)
let concat_map f l =
  let rec aux f acc = function
    | [] -> List.rev acc
    | x :: l ->
        let xs = f x in
        aux f (List.rev_append xs acc) l
  in
  aux f [] l

let () =
  C.main ~name:"leveldb" (fun c ->
      let default : C.Pkg_config.package_conf =
        { libs = [ "-lleveldb" ]; cflags = [] }
      in
      let conf =
        match C.Pkg_config.get c with
        | None -> default
        | Some pc -> (
            match C.Pkg_config.query pc ~package:"leveldb" with
            | None -> default
            | Some deps -> deps)
      in

      concat_map (fun flag -> [ "-cclib"; flag ]) conf.libs
      |> fun list -> List.concat [["-cclib"; "-lstdc++"]; list]
      |> C.Flags.write_sexp "flags.sexp")