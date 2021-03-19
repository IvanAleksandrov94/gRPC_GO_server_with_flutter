package main

import (
	"grpc-server/pkg/adder"
	"grpc-server/pkg/api"
	"log"
	"net"
	"google.golang.org/grpc"
)

func main() {
	s := grpc.NewServer()
	srv := &adder.GRPCServer{}

	api.RegisterAdderServer(s, srv)

	l, err := net.Listen("tcp", "localhost:4444")
	println("Server started: " + l.Addr().String())

	if err != nil {
		log.Fatal(err)
	}

	s.Serve(l)
	if err != nil {
		log.Fatal(err)
	}
}
