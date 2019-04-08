#!/bin/bash
//usr/bin/groovy -cp /opt/gakoci/hooks/spoon.jar "$0" "$@"; exit 0

/*
List all public classes in src/main/java using Spoon
*/

import spoon.reflect.declaration.CtType;
import spoon.reflect.declaration.CtClass;
import spoon.Launcher;
import spoon.processing.AbstractProcessor;
import spoon.reflect.declaration.ModifierKind;
import groovy.json.JsonSlurper

class ListClasses extends AbstractProcessor<CtType> {
  boolean isToBeProcessed(CtType c) {
    return c.isTopLevel() && c.getModifiers().contains(ModifierKind.PUBLIC);
  }
  void process(CtType c) {
    System.out.println(c.getQualifiedName());
  }
}
def l = new Launcher();
l.addInputResource("src/main/java");
def proc=new ListClasses();
l.addProcessor(proc);
l.getEnvironment().setNoClasspath(true);
l.run();
