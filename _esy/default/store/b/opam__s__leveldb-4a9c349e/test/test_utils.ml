
open Printf
open OUnit

let rounds = ref 1

let string_of_list f l = "[ " ^ String.concat "; " (List.map f l) ^ " ]"
let string_of_pair f (a, b) = sprintf "(%s, %s)" (f a) (f b)
let string_of_tuple2 f g (a, b) = sprintf "(%s, %s)" (f a) (g b)

let string_of_option f = function
    None -> "None"
  | Some x -> sprintf "Some %s" (f x)

let assert_failure_fmt fmt = Printf.ksprintf assert_failure fmt

let aeq_int = assert_equal ~printer:(sprintf "%d")
let aeq_bool = assert_equal ~printer:(sprintf "%b")
let aeq_string = assert_equal ~printer:(sprintf "%S")

let aeq_none ?msg x =
  assert_equal ?msg ~printer:(function None -> "None" | Some _ -> "Some _") None x

let cmp_tuple2 f g (a1, a2) (b1, b2) = f a1 b1 && g a2 b2

let cmp_option = function
    None -> fun o1 o2 -> compare o1 o2 = 0
  | Some f -> (fun x y -> match x, y with
                   None, Some _ | Some _, None -> false
                 | None, None -> true
                 | Some x, Some y -> f x y)

let cmp_list = function
    None -> fun l1 l2 -> compare l1 l2 = 0
  | Some f ->
      fun l1 l2 ->
        try
          List.fold_left2 (fun b x y -> b && f x y) true l1 l2
        with Invalid_argument _ -> false

let aeq_some ?msg ?cmp f x =
  assert_equal ?msg ~cmp:(cmp_option cmp) ~printer:(string_of_option f) (Some x)

let assert_not_found ?msg f =
  assert_raises ?msg Not_found (fun _ -> ignore (f ()))

let aeq_list ?cmp f =
  assert_equal ~cmp:(cmp_list cmp) ~printer:(string_of_list f)

let shuffle l =
  let a = Array.of_list l in
  let n = ref (Array.length a) in
    while !n > 1 do
      decr n;
      let k = Random.int (!n + 1) in
      let tmp = a.(k) in
        a.(k) <- a.(!n);
        a.(!n) <- tmp
    done;
    Array.to_list a

let make_temp_file ?(prefix = "temp") ?(suffix = ".dat") () =
  let file = Filename.temp_file prefix suffix in
    at_exit (fun () -> Sys.remove file);
    file

let make_temp_dir ?(prefix = "temp") () =
  let path = Filename.temp_file prefix "" in
    Sys.remove path;
    Unix.mkdir path 0o755;
    at_exit (fun () -> ignore (Sys.command (sprintf "rm -rf %S" path)));
    path

let random_list gen len =
  Array.to_list (Array.init len (fun _ -> gen ()))

let random_string () =
  let s = Bytes.create (10 + Random.int 4096) in
    for i = 0 to Bytes.length s - 1 do
      Bytes.set s i (Char.chr (Char.code 'a' + Random.int 26));
    done;
    s

let random_pair f g () = (f (), g ())
