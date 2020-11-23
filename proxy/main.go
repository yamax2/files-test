package main

import (
    "errors"
    "fmt"
    "io"
    "os"
    "path/filepath"
    "strings"
    "time"
    "net/http"
    "net"

    "github.com/pkg/sftp"
    "golang.org/x/crypto/ssh"
)

type sftpClient struct {
    host, user, password string
    port                 int
    *sftp.Client
}

// Create a new SFTP connection by given parameters
func NewConn(host, user, password string, port int) (client *sftpClient, err error) {
    switch {
    case `` == strings.TrimSpace(host),
	`` == strings.TrimSpace(user),
	`` == strings.TrimSpace(password),
	0 >= port || port > 65535:
	return nil, errors.New("Invalid parameters")
    }

    client = &sftpClient{
	host:     host,
	user:     user,
	password: password,
	port:     port,
    }

    if err = client.connect(); nil != err {
	return nil, err
    }
    return client, nil
}

func (sc *sftpClient) connect() (err error) {
    config := &ssh.ClientConfig{
        User:    sc.user,
        Auth:    []ssh.AuthMethod{ssh.Password(sc.password)},
        Timeout: 30 * time.Second,
        HostKeyCallback: func(hostname string, remote net.Addr, key ssh.PublicKey) error {
            return nil
        },
    }

    // connet to ssh
    addr := fmt.Sprintf("%s:%d", sc.host, sc.port)
    conn, err := ssh.Dial("tcp", addr, config)
    if err != nil {
	return err
    }

    // create sftp client
    client, err := sftp.NewClient(conn)
    if err != nil {
	return err
    }
    sc.Client = client

    return nil
}

// Upload file to sftp server
func (sc *sftpClient) Put(localFile, remoteFile string) (err error) {
    srcFile, err := os.Open(localFile)
    if err != nil {
	return
    }
    defer srcFile.Close()

    // Make remote directories recursion
    parent := filepath.Dir(remoteFile)
    path := string(filepath.Separator)
    dirs := strings.Split(parent, path)
    for _, dir := range dirs {
	path = filepath.Join(path, dir)
	sc.Mkdir(path)
    }

    dstFile, err := sc.Create(remoteFile)
    if err != nil {
	return
    }
    defer dstFile.Close()

    _, err = io.Copy(dstFile, srcFile)
    return
}

// Download file from sftp server
func (sc *sftpClient) Get(remoteFile, localFile string) (err error) {
    srcFile, err := sc.Open(remoteFile)
    if err != nil {
	    return
    }
    defer srcFile.Close()

    dstFile, err := os.Create(localFile)
    if err != nil {
	return
    }
    defer dstFile.Close()

    _, err = io.Copy(dstFile, srcFile)
    return
}

func download(w http.ResponseWriter, req *http.Request) {
  conn, err := NewConn("storage", "foo", "pass", 22)
  if err != nil {
        panic(err)
  }

  srcFile, err := conn.Open("upload/test")
  if err != nil {
  	    panic(err)
  }

  defer srcFile.Close()
  _, err = io.Copy(w, srcFile)
}

func main() {
  http.HandleFunc("/zozo", download)
  err := http.ListenAndServe("0.0.0.0:8090", nil)

  if err != nil {
    panic(err)
  }
}
