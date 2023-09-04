import FIND from "../utility/FIND.cdc"

pub fun main(name: String): Bool {
  return FIND.lookup(name) != nil
}