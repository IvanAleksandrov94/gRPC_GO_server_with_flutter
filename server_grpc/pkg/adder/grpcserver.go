package adder

import (
	"bufio"
	"bytes"
	"context"
	"grpc-server/pkg/api"
	"image"
	"image/draw"
	"image/jpeg"
	"image/png"
	"log"
	"os"
)

type GRPCServer struct {
}

func (s *GRPCServer) Add(ctx context.Context, req *api.AddRequest) (*api.AddResponse, error) {

	return &api.AddResponse{ImageResult: watermark(req.Image)}, nil
}

func watermark(imgByte []byte) []byte {
	img, _, err := image.Decode(bytes.NewReader(imgByte))
	if err != nil {
		log.Fatalln(err)
	}
	wmb, _ := os.Open("watermark1.png")
	watermark, _ := png.Decode(wmb)
	defer wmb.Close()

	offset := image.Pt(500, 500)
	b := img.Bounds()
	m := image.NewRGBA(b)
	draw.Draw(m, b, img, image.ZP, draw.Src)
	draw.Draw(m, watermark.Bounds().Add(offset), watermark, image.ZP, draw.Over)
	imgw, _ := os.Create("watermarked.jpg")
	jpeg.Encode(imgw, m, nil)
	defer imgw.Close()
	imageready, _ := os.Open("watermarked.jpg")

	stats, _ := imageready.Stat()
	var size int64 = stats.Size()
	bytes := make([]byte, size)
	bufr := bufio.NewReader(imageready)
	_, err = bufr.Read(bytes)

	return bytes

}
