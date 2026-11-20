function k3d-down --description 'delete a local k3d cluster: k3d-down [name]'
    k3d cluster delete (set -q argv[1]; and echo $argv[1]; or echo dev)
end
