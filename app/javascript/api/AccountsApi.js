// JsFromRoutes CacheKey 6b99264a67a6988e7f0387e35ad23b9d
//
// DO NOT MODIFY: This file was automatically generated by JsFromRoutes.
import { definePathHelper } from '@js-from-routes/client'

export default {
  list: definePathHelper('get', '/accounts'),
  create: definePathHelper('post', '/accounts'),
  new: definePathHelper('get', '/accounts/new'),
  edit: definePathHelper('get', '/accounts/:id/edit'),
  get: definePathHelper('get', '/accounts/:id'),
  update: definePathHelper('patch', '/accounts/:id'),
  destroy: definePathHelper('delete', '/accounts/:id'),
}