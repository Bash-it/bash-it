#!/bin/bash

function op_session_login {
	local TOKEN=$(op signin ${OP_ACCOUNT_NAME} --raw)
	export OP_SESSION_$OP_ACCOUNT_NAME=$TOKEN
	env | grep OP_SESSION_
}
