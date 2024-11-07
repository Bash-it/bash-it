FROM fedora
RUN yum install --assumeyes \
		ShellCheck \
		python-devel \
		python \
		golang \
		pip \
	&& \
	yum clean all
RUN pip3 install pre-commit
RUN GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt &&\
    ln -s ~/go/bin/shfmt /usr/local/bin
