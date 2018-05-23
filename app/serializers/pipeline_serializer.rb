class PipelineSerializer < BaseSerializer
  include WithPagination
  entity PipelineDetailsEntity

  def represent(resource, opts = {})
    if resource.is_a?(ActiveRecord::Relation)

      resource = resource.preload([
        :stages,
        :retryable_builds,
        :cancelable_statuses,
        :trigger_requests,
        :project,
        :manual_actions,
        :artifacts,
        { pending_builds: :project }
      ])
    end

    if opts.delete(:preload)
      resource = @paginator.paginate(resource) if paginated?
      resource = Gitlab::Ci::Pipeline::Preloader.preload!(resource)
    end

    super(resource, opts)
  end

  def represent_status(resource)
    return {} unless resource.present?

    data = represent(resource, { only: [{ details: [:status] }] })
    data.dig(:details, :status) || {}
  end

  def represent_stages(resource)
    return {} unless resource.present?

    data = represent(resource, { only: [{ details: [:stages] }] })
    data.dig(:details, :stages) || []
  end
end
