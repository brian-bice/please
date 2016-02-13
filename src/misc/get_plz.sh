#!/bin/sh
#
# Downloads a precompiled copy of Please from our s3 bucket and installs it.
set -eu

VERSION=`curl -s https://s3-eu-west-1.amazonaws.com/please-build/latest_version`
# Find the os / arch to download. You can do this quite nicely with go env
# but we use this script on machines that don't necessarily have Go itself.
OS=`uname`
if [ "$OS" = "Linux" ]; then
    GOOS="linux"
elif [ "$OS" = "Darwin" ]; then
    GOOS="darwin"
else
    echo "Unknown operating system $OS"
    exit 1
fi

PLEASE_URL="https://s3-eu-west-1.amazonaws.com/please-build/${GOOS}_amd64/${VERSION}/please.tar.gz"

LOCATION="${HOME}/.please"
DIR="${LOCATION}/${VERSION}"
mkdir -p "$DIR"

echo "Downloading Please ${VERSION} to ${DIR}..."
curl -fsSL "${PLEASE_URL}" | tar -xzpf- --strip-components=1 -C "$DIR"
# Link it all back up a dir
for x in `ls "$DIR"`; do
    ln -sf "${DIR}/${x}" "$LOCATION"
done
ln -sf "${DIR}/please" "${LOCATION}/plz"

if [ ! -f /usr/local/bin/plz ]; then
    sudo ln -sf "${LOCATION}/plz" /usr/local/bin/plz
fi
echo "Please installed."
plz --help
