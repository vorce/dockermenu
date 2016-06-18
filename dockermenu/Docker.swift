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
        dockerEnv()
    }
    
    /* Parse output from "docker-machine env default" into something we can do setenv on.
        TODO: Make "default" configurable
    */
    func dockerEnv() {
        let task = NSTask()
        let pipe = NSPipe()
        
        task.launchPath = "/usr/local/bin/docker-machine"
        task.arguments = ["env", "default"]
        task.standardOutput = pipe
        task.launch()
        
        let handle = pipe.fileHandleForReading
        let data = handle.readDataToEndOfFile()
        let result = NSString(data: data, encoding: NSUTF8StringEncoding)
        let lines = result!.componentsSeparatedByString("\n")
        let exportLines = lines.filter {$0 != "" }.filter { (line:String) -> Bool in
            line.containsString("export DOCKER")
        }
        
        let vars = exportLines.map { (line:String) -> EnvironmentVariable in
            let parts = line.componentsSeparatedByString(" ")
            let env = parts[1].componentsSeparatedByString("=")
            return EnvironmentVariable(name: env[0],
                value: env[1].stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil))
        }
        
        vars.forEach{ (ev: EnvironmentVariable) -> () in
            debugPrint("Setting env: " + ev.name + "=" + ev.value)
            setenv(ev.name, ev.value, 1)
        }
    }
    
    func dockerImages() -> [DockerImage] {
        let task = NSTask()
        let pipe = NSPipe()
        
        task.launchPath = "/usr/local/bin/docker"
        task.arguments = ["ps"]
        task.standardOutput = pipe
        task.launch()
        
        let handle = pipe.fileHandleForReading
        let data = handle.readDataToEndOfFile()
        let result = NSString(data: data, encoding: NSUTF8StringEncoding)
        return parseDockerPs(result as! String).sort({ (a:DockerImage, b:DockerImage) -> Bool in
            a.name < b.name
        })
    }
    
    func parseDockerPs(dockerPsOutput : String) -> [DockerImage] {
        let lines = dockerPsOutput.componentsSeparatedByString("\n")
        return lines.filter{ $0 != "" }.dropFirst().map { (line:String) -> DockerImage in
            let parts = line.componentsSeparatedByString(" ").filter {
                $0 != ""
            }
            return DockerImage(name: parts[1], containerId: parts[0])
        }
    }
    
    func stopAll(images: [DockerImage]) {
        debugPrint("Stopping all containers")
        images.forEach  { (image: DockerImage) -> () in
            stopContainer(image.containerId)
        }
    }
    
    func stopContainer(containerId: String) {
        debugPrint("Trying to stop container with id: " + containerId)
        let task = NSTask()
        task.launchPath = "/usr/local/bin/docker"
        task.arguments = ["stop", containerId]
        task.launch()
        task.waitUntilExit()
    }
}