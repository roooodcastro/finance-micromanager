import I18n from '~/utils/I18n.js';

export const editAction = (store) => {
  return {
    label: I18n.t('views.layout.grid_table.edit_action_label'),
    icon: 'pen-to-square',
    callback: row => store.openFormModal(row.id),
    variant: 'secondary',
    show: row => !row.disabledAt
  };
};

export const disableAction = (store) => {
  return {
    label: I18n.t('views.layout.grid_table.disable_action_label'),
    icon: 'ban',
    callback: row => store.disable(row.id),
    variant: 'danger',
    show: row => !row.disabledAt
  };
};

export const deleteAction = (store) => {
  return {
    label: I18n.t('views.layout.grid_table.delete_action_label'),
    icon: ['far', 'trash-can'],
    callback: row => store.destroy(row.id),
    variant: 'danger',
  };
};

export const reenableAction = (store) => {
  return {
    label: I18n.t('views.layout.grid_table.reenable_action_label'),
    icon: 'repeat',
    callback: row => store.reenable(row.id),
    variant: 'success',
    show: row => !!row.disabledAt
  };
};
