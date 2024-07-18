echo "==> Building the project..."
dune build
echo "==> OK"

echo "==> Formatting the project...."
dune build  @fmt --auto-promote
echo "==> OK"