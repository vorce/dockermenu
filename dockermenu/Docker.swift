//
//  Docker.swift
//  dockermenu
//
//  Created by Joel Carlbark on 2016-06-17.
//  Copyright © 2016 Joel Carlbark. All rights reserved.
//

import Foundation

class Docker {
    init() {
        setenv("PATH", "/usr/local/bin/", 1) // Needed by docker-machine, to know where VBoxManage is
        // TODO: Run this if docker toolbox is used, but not for Docker for Mac.
        // dockerEnv()
    }
    
    /* Parse output from "docker-machine env default" into something we can do setenv on.
        TODO: Make "default" configurable
    */
    func dockerEnv() {
        let task = Process()
        let pipe = Pipe()
        
        task.launchPath = "/usr/local/bin/docker-machine"
        task.arguments = ["env", "default"]
        task.standardOutput = pipe
        task.launch()
        
        let handle = pipe.fileHandleForReading
        let data = handle.readDataToEndOfFile()
        let result = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let lines = result!.components(separatedBy: "\n")
        let exportLines = lines.filter {$0 != "" }.filter { (line:String) -> Bool in
            line.contains("export DOCKER")
        }
        
        let vars = exportLines.map { (line:String) -> EnvironmentVariable in
            let parts = line.components(separatedBy: " ")
            let env = parts[1].components(separatedBy: "=")
            return EnvironmentVariable(name: env[0],
                value: env[1].replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil))
        }
        
        vars.forEach{ (ev: EnvironmentVariable) -> () in
            debugPrint("Setting env: " + ev.name + "=" + ev.value)
            setenv(ev.name, ev.value, 1)
        }
    }
    
    func dockerImages() -> [DockerImage] {
        let task = Process()
        let pipe = Pipe()
        
        task.launchPath = "/usr/local/bin/docker"
        task.arguments = ["ps"]
        task.standardOutput = pipe
        task.launch()
        
        let handle = pipe.fileHandleForReading
        let data = handle.readDataToEndOfFile()
        let result = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        return parseDockerPs(result! as String).sorted(by: { (a:DockerImage, b:DockerImage) -> Bool in
            a.name < b.name
        })
    }
    
    func parseDockerPs(_ dockerPsOutput : String) -> [DockerImage] {
        let lines = dockerPsOutput.components(separatedBy: "\n")
        return lines.filter{ $0 != "" }.dropFirst().map { (line:String) -> DockerImage in
            let parts = line.components(separatedBy: " ").filter {
                $0 != ""
            }
            return DockerImage(name: parts[1], containerId: parts[0])
        }
    }
    
    func stopAll(_ images: [DockerImage]) {
        debugPrint("Stopping all containers")
        images.forEach  { (image: DockerImage) -> () in
            stopContainer(image.containerId)
        }
    }
    
    func stopContainer(_ containerId: String) {
        debugPrint("Trying to stop container with id: " + containerId)
        let task = Process()
        task.launchPath = "/usr/local/bin/docker"
        task.arguments = ["stop", containerId]
        task.launch()
        task.waitUntilExit()
    }
}
