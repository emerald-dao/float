import "FIND"

access(all) fun main(name: String): Bool {
  return FIND.lookup(name) != nil
}