(lang dune 3.14)

(name simpleClientServerChat)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Gerard TE")

(maintainers "Gerard TE")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name simpleClientServerChat)
 (synopsis "A simple client-server chat")
 (description "A simple client-server chat in the context of exercise")
 (depends ocaml dune unix lwt)
 (tags
  (chat client server lwt socket)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
