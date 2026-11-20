function k3d-up --description 'create (or start) a local k3d cluster: k3d-up [name] [agents]'
    set -l name (set -q argv[1]; and echo $argv[1]; or echo dev)
    set -l agents (set -q argv[2]; and echo $argv[2]; or echo 1)
    if k3d cluster list -o json 2>/dev/null | jq -e --arg n $name '.[] | select(.name==$n)' >/dev/null
        k3d cluster start $name
    else
        k3d cluster create $name --agents $agents -p "8080:80@loadbalancer"
    end
    kubectl config use-context k3d-$name
end
