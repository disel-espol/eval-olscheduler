package main

import (
 "os"
 "fmt"
 "io/ioutil"
 "log"
 "path"
 "encoding/json"
 "bufio"
 "strings"
 "strconv"
 "sort"
)

type Handle struct {
 Handle string `json:"handle"`
 Pkgs []string `json:"pkgs"`
}

type byPkgSizeDesc []string

func (s byPkgSizeDesc) Len() int {
 return len(s)
}

func (s byPkgSizeDesc) Swap(i, j int) {
 s[i], s[j] = s[j], s[i]
}

func (s byPkgSizeDesc) Less(i, j int) bool {
 return pkgs[s[j]] < pkgs[s[i]]
}

var pkgs map[string]int

func main() {

 if len(os.Args) < 3 {
  log.Fatal("\nFirst parameter: handlers folder path\n" + 
  			"Second parameter: packages_and_size.txt")
  return 
 }
 args := os.Args[1:]
 handlersPath := args[0]
 pkgsAndSizePath := args[1]

 pkgs = make(map[string]int)
 {
  pkgsAndSizeFile, err := os.Open(pkgsAndSizePath)
  if err != nil {
   log.Fatal(err)
  }
  defer pkgsAndSizeFile.Close()
  scanner := bufio.NewScanner(pkgsAndSizeFile)
  for scanner.Scan() {
   line := scanner.Text()
   pkg := strings.Split(line, ":")
   size, _ := strconv.Atoi(pkg[1])
   pkgs[pkg[0]] = size
  }
  if err := scanner.Err(); err != nil {
   log.Fatal(err)
  }
 }
 // fmt.Printf("%+v", pkgs)


 handles, err := ioutil.ReadDir(handlersPath)
 if err != nil {
  log.Fatal(err) 
 }
 var registry []Handle
 for _, handleDir := range handles {
  var handle Handle
  handle.Handle = handleDir.Name()
  pkgsFilePath := path.Join(handlersPath, handleDir.Name(), "packages.txt")
  
  {
   pkgsFile, err := os.Open(pkgsFilePath)
   if err != nil {
    log.Fatal(err)
   }
   defer pkgsFile.Close()
   scanner := bufio.NewScanner(pkgsFile)
   for scanner.Scan() {
    line := scanner.Text()
    pkgs := strings.Split(line, ":")
    handle.Pkgs = append(handle.Pkgs, pkgs[1])
   }
   if err := scanner.Err(); err != nil {
    log.Fatal(err)
   }
   sort.Sort(byPkgSizeDesc(handle.Pkgs))
  }
  
  registry = append(registry, handle)
 }
 registryJson, _ := json.Marshal(registry)
 err = ioutil.WriteFile("registry.json", registryJson, 0644)
 fmt.Printf("%+v", registry)
}
