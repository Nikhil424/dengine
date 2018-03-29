if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
if [ -d ~/bin ] ; then
    PATH=~/bin:"${PATH}"
fi

export M2_HOME=/usr/share/maven
export M2=$M2_HOME/bin
export MAVEN_OPTS="-Xms256m -Xmx512m"
export PATH

